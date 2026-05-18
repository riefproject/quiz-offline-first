import 'package:flutter/material.dart';

import '../../../models/quiz_history_entry.dart';
import '../../../theme/colors_config.dart';

class QuizHistoryLeaderboardPage extends StatelessWidget {
  final QuizHistoryEntry entry;

  const QuizHistoryLeaderboardPage({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final leaderboard = entry.leaderboard;
    final topThree = leaderboard.take(3).toList(growable: false);
    final others = leaderboard.length > 3
        ? leaderboard.sublist(3)
        : const <QuizHistoryLeaderboardEntry>[];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'LEADERBOARD',
              style: textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              entry.quiz.judul,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.textOnSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDateTime(entry.session.waktuMulai)} • ${entry.participantCount} peserta',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            if (leaderboard.isEmpty)
              _NoLeaderboardState(entry: entry)
            else ...[
              if (topThree.isNotEmpty)
                _TopThreeSection(topThree: topThree),
              if (others.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Peringkat Lainnya',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.textOnSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...others.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LeaderboardRow(entry: item),
                  ),
                ),
              ],
            ],
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
}

class _TopThreeSection extends StatelessWidget {
  final List<QuizHistoryLeaderboardEntry> topThree;

  const _TopThreeSection({
    required this.topThree,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumCard(
            entry: topThree.length > 1 ? topThree[1] : null,
            height: 148,
            accentColor: const Color(0xFFC0CAD8),
            label: '2',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PodiumCard(
            entry: topThree.first,
            height: 184,
            accentColor: const Color(0xFFF0B74F),
            label: '1',
            isChampion: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PodiumCard(
            entry: topThree.length > 2 ? topThree[2] : null,
            height: 132,
            accentColor: const Color(0xFFD68C6A),
            label: '3',
          ),
        ),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final QuizHistoryLeaderboardEntry? entry;
  final double height;
  final Color accentColor;
  final String label;
  final bool isChampion;

  const _PodiumCard({
    required this.entry,
    required this.height,
    required this.accentColor,
    required this.label,
    this.isChampion = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final podiumEntry = entry;

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: isChampion ? 0.35 : 0.26),
            colors.surfaceLow,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.75),
          width: isChampion ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isChampion ? 0.18 : 0.1),
            blurRadius: isChampion ? 20 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: podiumEntry == null
          ? Center(
              child: Text(
                '-',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.mutedText,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    if (isChampion)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      podiumEntry.participantName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textOnSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${podiumEntry.score} pts',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.mutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final QuizHistoryLeaderboardEntry entry;

  const _LeaderboardRow({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              '#${entry.rank}',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.participantName,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textOnSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${entry.score} pts',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.textOnSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoLeaderboardState extends StatelessWidget {
  final QuizHistoryEntry entry;

  const _NoLeaderboardState({
    required this.entry,
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
          Icon(
            Icons.emoji_events_outlined,
            color: colors.primary,
            size: 40,
          ),
          const SizedBox(height: 14),
          Text(
            'Leaderboard belum tersedia',
            style: textTheme.titleMedium?.copyWith(
              color: colors.textOnSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sesi ${entry.session.id} belum memiliki hasil akhir yang tersimpan.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.mutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
