import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/quiz_result.dart';
import '../../../services/quiz_result_transfer_service.dart';
import '../../../theme/colors_config.dart';

class QuizResultQrPage extends StatefulWidget {
  static const String routeName = '/quiz-result-qr';

  final QuizResult quizResult;

  const QuizResultQrPage({
    super.key,
    required this.quizResult,
  });

  @override
  State<QuizResultQrPage> createState() => _QuizResultQrPageState();
}

class _QuizResultQrPageState extends State<QuizResultQrPage> {
  late final String _qrPayload;

  @override
  void initState() {
    super.initState();
    _qrPayload = QuizResultTransferService.encodeToQrPayload(
      widget.quizResult,
    );
  }

  Future<void> _copyPayload() async {
    await Clipboard.setData(ClipboardData(text: _qrPayload));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR payload copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final hasilAkhir = widget.quizResult.hasilAkhir;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reverse QR Export'),
      ),
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
                        data: _qrPayload,
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
                      'Scan this QR on the teacher device to import the result.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Result Summary',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Result ID', value: hasilAkhir.id),
                    _InfoRow(label: 'Session ID', value: hasilAkhir.idSesi),
                    _InfoRow(label: 'Student ID', value: hasilAkhir.idUser),
                    _InfoRow(
                      label: 'Score',
                      value: hasilAkhir.totalSkor.toString(),
                    ),
                    _InfoRow(
                      label: 'Rank',
                      value: hasilAkhir.peringkat.toString(),
                    ),
                    _InfoRow(
                      label: 'Answers',
                      value: widget.quizResult.answerCount.toString(),
                    ),
                    _InfoRow(
                      label: 'Payload Length',
                      value: '${_qrPayload.length} chars',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _copyPayload,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy Encoded Payload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

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
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.mutedText,
          fontWeight: FontWeight.w600,
        );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colors.textOnSurface,
          fontWeight: FontWeight.w600,
        );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: labelStyle),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
