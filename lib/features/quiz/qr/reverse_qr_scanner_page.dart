import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../models/reverse_qr_submission.dart';
import '../../../services/reverse_qr_sync_service.dart';
import '../../../theme/colors_config.dart';
import '../../../widgets/components/app_button.dart';

typedef ReverseQrImportCallback =
    Future<ReverseQrImportResult> Function(ReverseQrSubmission submission);

class ReverseQrScannerPage extends StatefulWidget {
  final ReverseQrImportCallback onImport;

  const ReverseQrScannerPage({
    super.key,
    required this.onImport,
  });

  @override
  State<ReverseQrScannerPage> createState() => _ReverseQrScannerPageState();
}

class _ReverseQrScannerPageState extends State<ReverseQrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isProcessing) {
      return;
    }

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere(
          (value) => value.trim().isNotEmpty,
          orElse: () => '',
        );

    if (rawValue.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await _scannerController.stop();
      final submission = ReverseQrSyncService.decodeSubmission(rawValue);
      final result = await widget.onImport(submission);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isProcessing = false;
      });
      await _scannerController.start();
    }
  }

  Future<void> _restartScanner() async {
    setState(() {
      _errorMessage = null;
      _isProcessing = false;
    });
    await _scannerController.start();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Mahasiswa'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetect,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.primary, width: 3),
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Arahkan kamera ke QR sinkronisasi peserta.',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade200,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    AppButton.outlined(
                      label: 'Scan Ulang',
                      onPressed: _restartScanner,
                      color: Colors.white,
                    ),
                  ] else if (_isProcessing) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
