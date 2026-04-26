import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/ble_service.dart';
import '../../services/ble_service_base.dart';
import '../../theme/colors_config.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';

class GuestJoinPage extends StatefulWidget {
  final BleServiceBase bleService;

  GuestJoinPage({super.key, BleServiceBase? bleService})
      : bleService = bleService ?? BleService();

  @override
  State<GuestJoinPage> createState() => _GuestJoinPageState();
}

class _GuestJoinPageState extends State<GuestJoinPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isSubmitting = false;
  bool _isScanning = false;
  bool _isInitializingBle = true;
  String? _scanError;

  @override
  void initState() {
    super.initState();
    _initializeBle();
  }

  Future<void> _initializeBle() async {
    try {
      await widget.bleService.init();
    } catch (e) {
      _scanError = 'BLE belum siap: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isInitializingBle = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    widget.bleService.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _scanError = null;
    });

    try {
      await widget.bleService.startScan(timeout: const Duration(seconds: 10));
      if (widget.bleService.rawScanData.value.isNotEmpty) {
        setState(() {
          _isScanning = false;
        });
      } else {
        setState(() {
          _isScanning = false;
          _scanError = 'No broadcasts found';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanError = 'Scan broadcast gagal: $e';
      });
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.continueAsGuest(
        namaLengkap: _nameController.text,
        joinCode: _codeController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/app');
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Guest join gagal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.primary.withValues(alpha: 0.45),
                    colors.backgroundSoft,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'Pulse Quiz',
                          style: textTheme.titleLarge?.copyWith(
                            color: colors.textOnPrimary,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      child: Text(
                        'Quiz smarter, compete together',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textOnSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: BoxDecoration(
                color: colors.surfaceLowest.withValues(alpha: 0.96),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 36,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outline,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Enter your name to join',
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.textOnSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick a nickname to start competing in live leagues.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Your display name',
                      hintText: 'e.g. QuizMaster99',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Session code (optional)',
                      hintText: 'Scan broadcast or enter code',
                      controller: _codeController,
                    ),
                    const SizedBox(height: 12),
                    AppButton.text(
                      label: _isInitializingBle
                          ? 'Preparing Bluetooth...'
                          : _isScanning
                              ? 'Scanning...'
                              : 'Scan Bluetooth Broadcast',
                      onPressed: _isInitializingBle || _isScanning ? null : _startScan,
                    ),
                    if (_scanError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _scanError!,
                        style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.secondary, const Color(0xFFFFB52E)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _continueAsGuest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: const Color(0xFF533000),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_isSubmitting ? 'Joining...' : 'Join Now'),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
