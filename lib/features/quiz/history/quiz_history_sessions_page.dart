import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/db_models.dart';
import '../../../models/quiz_history_entry.dart';
import '../../../services/hive_service.dart';
import '../../../services/quiz_history_service.dart';
import '../../../theme/colors_config.dart';
import 'quiz_history_leaderboard_page.dart';

class QuizHistorySessionsPage extends StatelessWidget {
  final Quiz quiz;

  const QuizHistorySessionsPage({
    super.key,
    required this.quiz,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            HiveService.sesiKuisBox.listenable(),
            HiveService.pesertaSesiBox.listenable(),
            HiveService.hasilAkhirBox.listenable(),
            HiveService.usersBox.listenable(),
            HiveService.soalBox.listenable(),
          ]),
          builder: (context, child) {
            final historyEntries = QuizHistoryService.loadHistoryForQuiz(quiz.id);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  'HISTORY QUIZ',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  quiz.judul,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.textOnSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (quiz.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    quiz.deskripsi,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.mutedText,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                if (historyEntries.isEmpty)
                  _EmptyHistoryState(quiz: quiz)
                else
                  ...historyEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SessionTile(
                        entry: entry,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuizHistoryLeaderboardPage(
                                entry: entry,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final QuizHistoryEntry entry;
  final VoidCallback onTap;

  const _SessionTile({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final startedAt = entry.session.waktuMulai;
    final finishedAt = entry.session.waktuSelesai ?? entry.session.waktuMulai;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateTime(startedAt),
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.textOnSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${entry.participantCount} peserta • ${entry.questionCount} soal • selesai ${_formatTimeOnly(finishedAt)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  static String _formatTimeOnly(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _EmptyHistoryState extends StatelessWidget {
  final Quiz quiz;

  const _EmptyHistoryState({
    required this.quiz,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              size: 34,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Belum ada riwayat sesi',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.textOnSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'History for "${quiz.judul}" will appear after a host session is completed and saved on this device.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.mutedText,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
