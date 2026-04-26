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

    final questionCount = HiveService.soalBox.values.where((s) => s.idQuiz == quiz.id).length;

    return AppCard(
      surface: CardSurface.lowest,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    quiz.judul,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textOnSurface,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (onEdit != null)
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: colors.mutedText,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                if (onDelete != null)
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: colors.mutedText,
                      ),
                    ),
                  ),
              ],
            ),
            if (quiz.deskripsi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                quiz.deskripsi,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.mutedText,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Chips row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppInfoChip(
                  icon: Icons.quiz_outlined,
                  label: '$questionCount Qs',
                ),
                AppInfoChip(
                  icon: Icons.person_outline,
                  label: quiz.pembuat,
                ),
                AppInfoChip(
                  icon: quiz.isSynced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                  label: quiz.isSynced ? 'Synced' : 'Pending',
                  isSynced: quiz.isSynced,
                  tintColor: quiz.isSynced
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF8C6D00),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Start button - with play icon
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}