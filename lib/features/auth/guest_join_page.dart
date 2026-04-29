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

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        decoration: BoxDecoration(
          color: colors.surfaceLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
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
              const SizedBox(height: 24),
              Text(
                'Enter your name to join',
                style: textTheme.titleLarge?.copyWith(
                  color: colors.textOnSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a nickname to start competing in live leagues.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textOnSurface,
                ),
              ),
              const SizedBox(height: 24),
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
                  style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton.primary(
                label: _isSubmitting ? 'Joining...' : 'Join Now',
                onPressed: _isSubmitting ? null : _continueAsGuest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
