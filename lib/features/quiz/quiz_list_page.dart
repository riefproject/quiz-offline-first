import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    return AppShell(
      header: AppTopHeader(
        title: 'Intelligent Quiz',
        subtitle: 'Offline quiz workspace',
        trailing: CircleAvatar(
          radius: 20,
          backgroundColor: colors.primary.withValues(alpha: 0.14),
          child: Text(
            'AR',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
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
}