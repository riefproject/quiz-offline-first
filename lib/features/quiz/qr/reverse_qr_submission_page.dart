import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/reverse_qr_submission.dart';
import '../../../services/reverse_qr_sync_service.dart';
import '../../../theme/colors_config.dart';
import '../../../widgets/components/app_button.dart';

class ReverseQrSubmissionPage extends StatefulWidget {
  final ReverseQrSubmission submission;

  const ReverseQrSubmissionPage({
    super.key,
    required this.submission,
  });

  @override
  State<ReverseQrSubmissionPage> createState() => _ReverseQrSubmissionPageState();
}

class _ReverseQrSubmissionPageState extends State<ReverseQrSubmissionPage> {
  late final String _payload;

  @override
  void initState() {
    super.initState();
    _payload = ReverseQrSyncService.encodeSubmission(widget.submission);
  }

  Future<void> _copyPayload() async {
    await Clipboard.setData(ClipboardData(text: _payload));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Payload copied successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('QR Sinkronisasi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surfaceLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: QrImageView(
                        data: _payload,
                        version: QrVersions.auto,
                        size: 280,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: colors.primary,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: colors.textOnSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Show this QR to the instructor if Bluetooth synchronization fails.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                title: 'Ringkasan',
                rows: [
                  ('Nama', widget.submission.participantName),
                  ('Game ID', widget.submission.gameId.toString()),
                  ('Client ID', widget.submission.clientId.toString()),
                  ('Jawaban', '${widget.submission.submittedAnswerCount} terkirim'),
                  ('Panjang payload', '${_payload.length} karakter'),
                ],
              ),
              const SizedBox(height: 16),
              AppButton.outlined(
                label: 'Salin Payload',
                onPressed: _copyPayload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;

  const _SummaryCard({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          for (var index = 0; index < rows.length; index++)
            Padding(
              padding: EdgeInsets.only(bottom: index == rows.length - 1 ? 0 : 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[index].$1,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rows[index].$2,
                      textAlign: TextAlign.right,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
