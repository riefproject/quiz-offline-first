import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import 'logger.dart';

class AudioService {
  AudioService._();

  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _jinglePlayer;

  static const _bgmTracks = [
    'audio/bgm/Points_On_The_Line.mp3',
    'audio/bgm/Top_of_the_Leaderboard.mp3',
  ];

  AudioPlayer _getPlayer(String which) {
    switch (which) {
      case 'bgm':
        return _bgmPlayer ??= AudioPlayer();
      case 'sfx':
        return _sfxPlayer ??= AudioPlayer();
      case 'jingle':
        return _jinglePlayer ??= AudioPlayer();
      default:
        return AudioPlayer();
    }
  }

  Future<void> playBgm() async {
    try {
      final track = _bgmTracks[Random().nextInt(_bgmTracks.length)];
      final p = _getPlayer('bgm');
      await p.setReleaseMode(ReleaseMode.loop);
      await p.play(AssetSource(track));
      log.i('AudioService: BGM started — $track');
    } catch (e) {
      log.e('AudioService: playBgm failed — $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer?.stop();
      log.i('AudioService: BGM stopped');
    } catch (e) {
      log.e('AudioService: stopBgm failed — $e');
    }
  }

  void playTick() {
    _getPlayer('sfx')
        .play(AssetSource('audio/sfx/tick.mp3'))
        .catchError((e) => log.e('AudioService: playTick failed — $e'));
  }

  Future<void> playFanfare() async {
    try {
      await _getPlayer('jingle').play(
        AssetSource('audio/jingle/fanfare-trumpets.mp3'),
      );
      log.i('AudioService: fanfare played');
    } catch (e) {
      log.e('AudioService: playFanfare failed — $e');
    }
  }

  void dispose() {
    _bgmPlayer?.dispose();
    _sfxPlayer?.dispose();
    _jinglePlayer?.dispose();
  }
}
