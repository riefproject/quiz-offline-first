import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/layout/app_bottom_navigation.dart';
import '../../widgets/layout/app_shell.dart';
import '../../widgets/layout/app_top_header.dart';
import '../../models/quiz_collection_item.dart';
import '../../theme/colors_config.dart';
import 'widgets/create_quiz_card.dart';
import 'widgets/quiz_card.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  int _currentNavIndex = 1;

  void _handleNavigationTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final session = AuthService.currentSession;
    final initials = _buildInitials(session?.displayName ?? 'AR');

    return AppShell(
      header: AppTopHeader(
        title: 'Intelligent Quiz',
        subtitle: 'Offline quiz workspace',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceLowest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.outline),
              ),
              child: IconButton(
                onPressed: _logout,
                tooltip: 'Log Out',
                icon: Icon(
                  Icons.logout_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primary.withValues(alpha: 0.14),
              child: Text(
                initials,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigationTap,
        destinations: const [
          AppNavDestination(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
          ),
          AppNavDestination(
            label: 'Quizzes',
            icon: Icons.view_list_outlined,
            activeIcon: Icons.view_list_rounded,
          ),
          AppNavDestination(
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const AppSearchField(),
          const SizedBox(height: 20),
          const AppSectionLabel(
            eyebrow: 'YOUR COLLECTION',
            title: 'My Quizzes',
          ),
          const SizedBox(height: 18),
          ...QuizCollectionItem.samples.map(
            (quiz) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: QuizCard(
                quiz: quiz,
                onEdit: () {},
                onStart: () {},
              ),
            ),
          ),
          const SizedBox(height: 4),
          CreateQuizCard(
            onTap: () {},
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AR';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
