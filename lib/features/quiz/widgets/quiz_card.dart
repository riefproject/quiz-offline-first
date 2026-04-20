import 'package:flutter/material.dart';

import '../../../widgets/components/app_button.dart';
import '../../../widgets/components/app_card.dart';
import '../../../models/quiz_collection_item.dart';
import '../../../theme/colors_config.dart';
import '../../../widgets/app_info_chip.dart';

class QuizCard extends StatelessWidget {
  final QuizCollectionItem quiz;
  final VoidCallback onStart;
  final VoidCallback? onEdit;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.onStart,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      surface: CardSurface.lowest,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: quiz.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    quiz.icon,
                    color: quiz.accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              quiz.title,
                              style: textTheme.titleMedium?.copyWith(
                                color: colors.textOnSurface,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (onEdit != null)
                            IconButton(
                              onPressed: onEdit,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: colors.mutedText,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quiz.description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.mutedText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AppInfoChip(
                  icon: Icons.quiz_outlined,
                  label: '${quiz.questionCount} Qs',
                  tintColor: quiz.accentColor,
                ),
                AppInfoChip(
                  icon: Icons.schedule_rounded,
                  label: '${quiz.estimatedMinutes} min',
                  tintColor: colors.primary,
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                label: 'Start Session',
                onPressed: onStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}