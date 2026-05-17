import 'package:flutter/material.dart';

import '../../../theme/colors_config.dart';

class FirstQuestionCountdown extends StatelessWidget {
  final int remainingMs;
  final int totalMs;
  final String questionLabel;
  final int? participantCount;

  const FirstQuestionCountdown({
    super.key,
    required this.remainingMs,
    this.totalMs = 5000,
    this.questionLabel = 'Question 1',
    this.participantCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final maxSeconds = (totalMs / 1000).ceil();
    final seconds = (remainingMs / 1000).ceil().clamp(1, maxSeconds);
    final progress = (remainingMs / totalMs).clamp(0.0, 1.0).toDouble();

    return Material(
      color: colors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
              ),
              const Spacer(),
              Text(
                'Get Ready',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.textOnPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The quiz starts in',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colors.textOnPrimary.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 34),
              Center(
                child: SizedBox(
                  width: 214,
                  height: 214,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          backgroundColor: colors.textOnPrimary.withValues(
                            alpha: 0.16,
                          ),
                          color: colors.textOnPrimary,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 520),
                        switchInCurve: Curves.elasticOut,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final scale = Tween<double>(
                            begin: 0.54,
                            end: 1,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          '$seconds',
                          key: ValueKey(seconds),
                          style: textTheme.displayLarge?.copyWith(
                            color: colors.textOnPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 112,
                            height: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 34),
              if (participantCount != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      color: colors.textOnPrimary.withValues(alpha: 0.72),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$participantCount participant(s) ready',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textOnPrimary.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
