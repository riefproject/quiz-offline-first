import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:AlpenQuiz/config.dart';
import 'package:AlpenQuiz/services/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';

const _discoveryPort = 49152;
const _discoveryPrefix = 'KAHOOF_DISCOVER';
const _defaultWsPort = 8080;

class DiscoveredGame {
  final int gameId;
  final int questionCount;
  final String hostIp;
  final int wsPort;
  final String hostName;

  const DiscoveredGame({
    required this.gameId,
    required this.questionCount,
    required this.hostIp,
    required this.wsPort,
    required this.hostName,
  });
}

class LanService {
  // --- Host mode state ---
  HttpServer? _server;
  final _clients = <WebSocket>{};
  final _clientDataController =
      StreamController<(String, Uint8List)>.broadcast();
  RawDatagramSocket? _udpSender;
  Timer? _discoveryTimer;

  int? _gameId;
  int? _questionCount;
  int _wsPort = _defaultWsPort;
  bool _isHost = false;

  // --- Client mode state ---
  WebSocket? _socket;
  final _hostDataController = StreamController<Uint8List>.broadcast();
  bool _isClient = false;

  // --- Discovery mode state ---
  RawDatagramSocket? _udpListener;
  final _discoveryController = StreamController<DiscoveredGame>.broadcast();
  bool _isDiscovery = false;

  // ---- Public streams ----

  /// Host mode: raw bytes from clients, keyed by a per-connection id.
  Stream<(String, Uint8List)> get onClientData => _clientDataController.stream;

  /// Client mode: raw bytes from the host.
  Stream<Uint8List> get onHostData => _hostDataController.stream;

  /// Discovery mode: games found via UDP broadcast.
  Stream<DiscoveredGame> get onGameDiscovered => _discoveryController.stream;

  /// The local WebSocket port (host mode).
  int get wsPort => _wsPort;

  bool get isRunning => _isHost || _isClient || _isDiscovery;

  LanService._();

  // ---------------------------------------------------------------
  // Host factory – starts WebSocket server + UDP discovery broadcast
  // ---------------------------------------------------------------
  static Future<LanService> host({
    required int gameId,
    required int questionCount,
    String hostName = 'Quiz Host',
    int wsPort = _defaultWsPort,
  }) async {
    final service = LanService._();

    if (Config.isSessionMocked) {
      return LanMockService.host(
        gameId: gameId,
        questionCount: questionCount,
        hostName: hostName,
        wsPort: wsPort,
      );
    }

    service._gameId = gameId;
    service._questionCount = questionCount;
    service._wsPort = wsPort;
    service._isHost = true;

    service._server = await HttpServer.bind(InternetAddress.anyIPv4, wsPort);
    log.i('LanService: WS server listening on port $wsPort');

    service._server!.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      final remoteAddr =
          (request.response as dynamic)
              .connectionInfo
              ?.remoteAddress
              ?.address ??
          'unknown';
      log.i('LanService: client connected from $remoteAddr');
      service._clients.add(socket);

      socket.listen(
        (data) {
          if (data is Uint8List || data is List<int>) {
            final bytes = data is Uint8List
                ? data
                : Uint8List.fromList(data as List<int>);
            log.d('LanService: received ${bytes.length}bytes from $remoteAddr');
            service._clientDataController.add((remoteAddr, bytes));
          }
        },
        onDone: () {
          log.i('LanService: client disconnected $remoteAddr');
          service._clients.remove(socket);
        },
        onError: (e) {
          log.w('LanService: client error $remoteAddr — $e');
          service._clients.remove(socket);
        },
      );
    });

    _startDiscoveryBroadcast(service);

    log.i(
      'LanService(h): ready gameId=$gameId questionCount=$questionCount wsPort=$wsPort',
    );
    return service;
  }

  static void _startDiscoveryBroadcast(LanService service) {
    final msg =
        '$_discoveryPrefix|${service._gameId}|${service._questionCount}|${service._wsPort}|Quiz Host';
    final data = utf8.encode(msg);

    _sendUdpBroadcast(data, service);

    service._discoveryTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _sendUdpBroadcast(data, service),
    );
  }

  Future<InternetAddress?> getHotspotBroadcastAddress() async {
    try {
      // 1. Get all active network interfaces on the device
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      for (var interface in interfaces) {
        for (var address in interface.addresses) {
          final ip = address.address;

          // 2. Filter for standard private Mobile Hotspot ranges
          // This prevents us from accidentally grabbing the cellular 4G/5G IP
          bool isAndroidHotspot = ip.startsWith('192.168.');
          bool isIosHotspot = ip.startsWith('172.20.');
          bool isGeneralPrivate = ip.startsWith('10.');

          if (isAndroidHotspot || isIosHotspot || isGeneralPrivate) {
            // 3. Apply the /24 subnet hack
            List<String> octets = ip.split('.');
            if (octets.length == 4) {
              octets[3] =
                  '255'; // Force the last octet to 255 for the broadcast

              String broadcastIp = octets.join('.');
              log.d("Found Hotspot Interface: $ip");
              log.d("Calculated Broadcast: $broadcastIp");

              return InternetAddress(broadcastIp);
            }
          }
        }
      }
    } catch (e) {
      log.e("Error scanning interfaces: $e");
    }

    return null; // Return null if nothing is found
  }

  static Future<void> _sendUdpBroadcast(
    List<int> data,
    LanService service,
  ) async {
    try {
      final broadcastIp = await service.getHotspotBroadcastAddress();
      log.d('LanService: Sending UDP broadcast to $broadcastIp');
      if (broadcastIp == null) return;

      service._udpSender ??= await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      service._udpSender!.broadcastEnabled = true;
      service._udpSender!.send(data, broadcastIp, _discoveryPort);
      log.d(
        'LanService: UDP discovery broadcast sent ${data.length}byte to $broadcastIp',
      );
    } catch (e) {
      log.w('LanService: UDP broadcast failed — $e');
    }
  }

  // ---------------------------------------------------------------
  // Client factory – connects to host WebSocket
  // ---------------------------------------------------------------
  static Future<LanService> client({
    required String hostIp,
    required int wsPort,
    required int gameId,
    required String playerName,
    required int clientId,
  }) async {
    final service = LanService._();

    if (Config.isSessionMocked) {
      return LanMockService.client(
        hostIp: hostIp,
        wsPort: wsPort,
        gameId: gameId,
        playerName: playerName,
        clientId: clientId,
      );
    }

    service._isClient = true;

    try {
      service._socket = await WebSocket.connect('ws://$hostIp:$wsPort');
      log.i('LanService: connected to host $hostIp:$wsPort');
    } catch (e) {
      log.e('LanService: failed to connect to $hostIp:$wsPort — $e');
      rethrow;
    }

    service._socket!.listen(
      (data) {
        if (data is Uint8List || data is List<int>) {
          final bytes = data is Uint8List
              ? data
              : Uint8List.fromList(data as List<int>);
          log.d('LanService: received ${bytes.length}bytes from host');
          service._hostDataController.add(bytes);
        }
      },
      onDone: () {
        log.i('LanService: host connection closed');
        service._hostDataController.close();
      },
      onError: (e) {
        log.w('LanService: host connection error — $e');
        service._hostDataController.close();
      },
    );

    return service;
  }

  // ---------------------------------------------------------------
  // Discovery factory – listens for UDP broadcast announcements
  // ---------------------------------------------------------------
  static Future<LanService> discovery() async {
    final service = LanService._();

    if (Config.isSessionMocked) {
      return LanMockService.discovery();
    }

    service._isDiscovery = true;

    try {
      service._udpListener = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _discoveryPort,
      );
      log.i('LanService: UDP discovery listener on port $_discoveryPort');

      service._udpListener!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = service._udpListener!.receive();
          if (datagram == null) return;
          final msg = utf8.decode(datagram.data);
          _parseDiscoveryPacket(msg, datagram.address.address, service);
        }
      });
    } catch (e) {
      log.w('LanService: UDP discovery bind failed — $e');
    }

    return service;
  }

  static void _parseDiscoveryPacket(
    String msg,
    String sourceIp,
    LanService service,
  ) {
    if (!msg.startsWith(_discoveryPrefix)) return;
    final parts = msg.split('|');
    if (parts.length < 4) return;

    final gameId = int.tryParse(parts[1]);
    final questionCount = int.tryParse(parts[2]);
    final wsPort = int.tryParse(parts[3]);
    final hostName = parts.length > 4 ? parts[4] : 'Quiz Host';

    if (gameId == null || questionCount == null || wsPort == null) return;

    final discovered = DiscoveredGame(
      gameId: gameId,
      questionCount: questionCount,
      hostIp: sourceIp,
      wsPort: wsPort,
      hostName: hostName,
    );

    log.i(
      'LanService: discovered gameId=$gameId host=$sourceIp:$wsPort questionCount=$questionCount',
    );
    service._discoveryController.add(discovered);
  }

  // ---------------------------------------------------------------
  // Send methods
  // ---------------------------------------------------------------

  /// Host: broadcast raw bytes to all connected clients.
  void broadcast(Uint8List data) {
    if (!_isHost) {
      log.w('LanService: broadcast called but not in host mode');
      return;
    }
    if (Config.isSessionMocked) {
      (this as LanMockService).mockBroadcast(data);
      return;
    }
    log.d(
      'LanService: broadcasting ${data.length}bytes to ${_clients.length} client(s)',
    );
    for (final client in _clients) {
      client.add(data);
    }
  }

  /// Client: send raw bytes to the host.
  void sendToHost(Uint8List data) {
    if (!_isClient) {
      log.w('LanService: sendToHost called but not in client mode');
      return;
    }
    if (Config.isSessionMocked) {
      (this as LanMockService).mockSendToHost(data);
      return;
    }
    log.d('LanService: sending ${data.length}bytes to host');
    _socket?.add(data);
  }

  // ---------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------
  void dispose() {
    log.i(
      'LanService: disposing (host=$_isHost client=$_isClient discovery=$_isDiscovery)',
    );

    _discoveryTimer?.cancel();
    _discoveryTimer = null;

    _udpSender?.close();
    _udpSender = null;

    _udpListener?.close();
    _udpListener = null;

    for (final client in _clients) {
      client.close();
    }
    _clients.clear();

    _server?.close();
    _server = null;

    _socket?.close();
    _socket = null;

    _clientDataController.close();
    _hostDataController.close();
    _discoveryController.close();

    _isHost = false;
    _isClient = false;
    _isDiscovery = false;
  }
}

// =================================================================
// Mock implementation for simulator testing (MOCK_SESSION=true)
// =================================================================

class LanMockService extends LanService {
  static final _buses = <int, _SharedBus>{};
  static final _discoverySink = StreamController<DiscoveredGame>.broadcast();

  int? _mockGameId;

  @override
  Stream<DiscoveredGame> get onGameDiscovered => _discoverySink.stream;

  static LanMockService host({
    required int gameId,
    required int questionCount,
    String hostName = 'Quiz Host',
    int wsPort = _defaultWsPort,
  }) {
    final service = LanMockService._();
    service._gameId = gameId;
    service._questionCount = questionCount;
    service._wsPort = wsPort;
    service._isHost = true;
    service._mockGameId = gameId;

    _buses[gameId] = _SharedBus();
    log.i('LanMockService(h): created bus for gameId=$gameId');

    _discoverySink.add(
      DiscoveredGame(
        gameId: gameId,
        questionCount: questionCount,
        hostIp: '127.0.0.1',
        wsPort: wsPort,
        hostName: hostName,
      ),
    );
    log.i('LanMockService(h): discovery announced gameId=$gameId');

    final bus = _buses[gameId]!;
    bus.clientsToHost.stream.listen((data) {
      log.d('LanMockService(h): client data ${data.$2.length}bytes');
      service._clientDataController.add(data);
    });

    return service;
  }

  static LanMockService client({
    required String hostIp,
    required int wsPort,
    required int gameId,
    required String playerName,
    required int clientId,
  }) {
    final service = LanMockService._();
    service._isClient = true;
    service._mockGameId = gameId;

    final bus = _buses[gameId];
    if (bus == null) {
      log.w('LanMockService(c): no bus for gameId=$gameId');
    } else {
      log.i(
        'LanMockService(c): connected to gameId=$gameId clientId=$clientId',
      );
      bus.hostToClients.stream.listen((data) {
        log.d('LanMockService(c): host data ${data.length}bytes');
        service._hostDataController.add(data);
      });
    }

    return service;
  }

  static LanMockService discovery() {
    final service = LanMockService._();
    service._isDiscovery = true;
    log.i('LanMockService(d): discovery mode ready');
    return service;
  }

  LanMockService._() : super._();

  void mockBroadcast(Uint8List data) {
    if (_mockGameId == null) return;
    final bus = _buses[_mockGameId];
    if (bus == null) return;
    log.d('LanMockService(h): mock broadcast ${data.length}bytes');
    bus.hostToClients.add(data);
  }

  void mockSendToHost(Uint8List data) {
    if (_mockGameId == null) return;
    final bus = _buses[_mockGameId];
    if (bus == null) return;
    final clientId = 'mock-client-${_mockGameId}';
    log.d('LanMockService(c): mock send ${data.length}bytes');
    bus.clientsToHost.add((clientId, data));
  }

  @override
  void dispose() {
    if (_isHost && _mockGameId != null) {
      _buses[_mockGameId]?.dispose();
      _buses.remove(_mockGameId);
    }
    super.dispose();
  }
}

class _SharedBus {
  final hostToClients = StreamController<Uint8List>.broadcast();
  final clientsToHost = StreamController<(String, Uint8List)>.broadcast();

  void dispose() {
    hostToClients.close();
    clientsToHost.close();
  }
}
