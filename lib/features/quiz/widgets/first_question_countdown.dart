import 'dart:io';

import 'package:flutter/material.dart';

import '../../../theme/colors_config.dart';

class FirstQuestionCountdown extends StatelessWidget {
  final int remainingMs;
  final int totalMs;
  final String questionLabel;
  final int? participantCount;
  final String? questionText;
  final List<String>? questionOptions;
  final String? questionPhotoUrl;
  final String? questionLocalPhotoPath;

  const FirstQuestionCountdown({
    super.key,
    required this.remainingMs,
    this.totalMs = 5000,
    this.questionLabel = 'Question 1',
    this.participantCount,
    this.questionText,
    this.questionOptions,
    this.questionPhotoUrl,
    this.questionLocalPhotoPath,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final maxSeconds = (totalMs / 1000).ceil();
    final seconds = (remainingMs / 1000).ceil().clamp(1, maxSeconds).toInt();
    final progress = (remainingMs / totalMs).clamp(0.0, 1.0).toDouble();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final optionColors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.yellow.shade700,
      Colors.green.shade400,
    ];

    return Material(
      color: colors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: isLandscape
              ? _buildLandscapeCountdown(
                  context,
                  colors,
                  textTheme,
                  seconds,
                  progress,
                  optionColors,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuestionLabel(colors, textTheme),
                    const SizedBox(height: 12),
                    if (questionText != null) ...[
                      _buildQuestionPreview(colors, textTheme),
                      const SizedBox(height: 12),
                      if (questionOptions != null)
                        ...questionOptions!.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _buildOptionChip(
                              e.key,
                              e.value,
                              optionColors[e.key % optionColors.length],
                              textTheme,
                            ),
                          );
                        }),
                      const Spacer(),
                    ] else
                      const Spacer(),
                    Text(
                      'Get Ready',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: colors.textOnPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The quiz starts in',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.textOnPrimary.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 6,
                                strokeCap: StrokeCap.round,
                                backgroundColor: colors.textOnPrimary.withValues(alpha: 0.16),
                                color: colors.textOnPrimary,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 520),
                              switchInCurve: Curves.elasticOut,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final scale = Tween<double>(begin: 0.54, end: 1).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(scale: scale, child: child),
                                );
                              },
                              child: Text(
                                '$seconds',
                                key: ValueKey(seconds),
                                style: textTheme.displayLarge?.copyWith(
                                  color: colors.textOnPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 72,
                                  height: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (participantCount != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_alt_rounded, color: colors.textOnPrimary.withValues(alpha: 0.72), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '$participantCount participant(s) ready',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textOnPrimary.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildQuestionLabel(ColorsConfig colors, TextTheme textTheme) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colors.textOnPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          questionLabel.toUpperCase(),
          style: textTheme.labelLarge?.copyWith(
            color: colors.textOnPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPreview(ColorsConfig colors, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          questionText!,
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        if ((questionLocalPhotoPath != null && questionLocalPhotoPath!.isNotEmpty) ||
            (questionPhotoUrl != null && questionPhotoUrl!.isNotEmpty))
          Container(
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: questionLocalPhotoPath != null && questionLocalPhotoPath!.isNotEmpty
                  ? Image.file(
                      File(questionLocalPhotoPath!),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => questionPhotoUrl != null
                          ? Image.network(questionPhotoUrl!, height: 120, width: double.infinity, fit: BoxFit.cover)
                          : const SizedBox.shrink(),
                    )
                  : Image.network(questionPhotoUrl!, height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionChip(
    int index,
    String label,
    Color color,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Text(
            String.fromCharCode(65 + index),
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeCountdown(
    BuildContext context,
    ColorsConfig colors,
    TextTheme textTheme,
    int seconds,
    double progress,
    List<Color> optionColors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuestionLabel(colors, textTheme),
              const SizedBox(height: 12),
              if (questionText != null) ...[
                _buildQuestionPreview(colors, textTheme),
                const SizedBox(height: 10),
                if (questionOptions != null)
                  ...questionOptions!.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _buildOptionChip(
                        e.key,
                        e.value,
                        optionColors[e.key % optionColors.length],
                        textTheme,
                      ),
                    );
                  }),
              ],
              const Spacer(),
              if (participantCount != null)
                Row(
                  children: [
                    Icon(Icons.people_alt_rounded, color: colors.textOnPrimary.withValues(alpha: 0.72), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$participantCount participant(s) ready',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textOnPrimary.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Ready',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: colors.textOnPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'The quiz starts in',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textOnPrimary.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: colors.textOnPrimary.withValues(alpha: 0.16),
                      color: colors.textOnPrimary,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 520),
                    switchInCurve: Curves.elasticOut,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final scale = Tween<double>(begin: 0.54, end: 1).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: scale, child: child),
                      );
                    },
                    child: Text(
                      '$seconds',
                      key: ValueKey(seconds),
                      style: textTheme.displayLarge?.copyWith(
                        color: colors.textOnPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 60,
                        height: 0.9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
