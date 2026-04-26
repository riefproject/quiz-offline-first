import 'package:flutter/material.dart';

import '../../../widgets/components/app_button.dart';
import '../../../widgets/components/app_card.dart';
import '../../../models/db_models.dart';
import '../../../theme/colors_config.dart';
import '../../../widgets/app_info_chip.dart';
import '../../../services/hive_service.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onStart;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.onStart,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    // Menghitung jumlah pertanyaan (dari hive box soalBox)
    final questionCount = HiveService.soalBox.values.where((s) => s.idQuiz == quiz.id).length;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              quiz.judul,
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
                          const SizedBox(width: 8),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.redAccent,
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
                        quiz.deskripsi,
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
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppInfoChip(
                  icon: Icons.quiz_outlined,
                  label: '$questionCount Qs',
                  tintColor: colors.primary,
                ),
                AppInfoChip(
                  icon: Icons.person_outline,
                  label: quiz.pembuat,
                  tintColor: Colors.blueAccent,
                ),
                // Sync Indicator
                Tooltip(
                  message: quiz.isSynced ? 'Tersinkronisasi' : 'Belum Tersinkronisasi',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: quiz.isSynced 
                          ? Colors.green.withValues(alpha: 0.1) 
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          quiz.isSynced ? Icons.cloud_done : Icons.cloud_upload,
                          size: 14,
                          color: quiz.isSynced ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          quiz.isSynced ? 'Synced' : 'Pending',
                          style: textTheme.bodySmall?.copyWith(
                            color: quiz.isSynced ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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