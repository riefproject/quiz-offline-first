import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../services/quiz_sync_service.dart';
import 'controllers/quiz_controller.dart';
import '../../models/db_models.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/layout/app_bottom_navigation.dart';
import '../../widgets/layout/app_shell.dart';
import '../../widgets/layout/app_top_header.dart';
import '../../theme/colors_config.dart';
import '../../widgets/components/app_confirm_modal.dart';
import 'client/client_view.dart';
import 'client/client_controller.dart';
import 'widgets/create_quiz_card.dart';
import 'history/quiz_history_sessions_page.dart';
import 'widgets/quiz_card.dart';
import 'create_quiz_page.dart';
import '../profile/screens/profile_screen.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  int _currentNavIndex = 1;
  final _quizController = QuizController();

  bool _showBottomBar = true;

  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    QuizSyncService().initialize();
  }

  void _handleNavigationTap(int index) {
    setState(() {
      _currentNavIndex = index;
      if (index != 0) {
        _showBottomBar = true;
      }
    });
  }

  Future<void> _deleteQuiz(String quizId) async {
    final confirm = await AppConfirmModal.show(
      context,
      title: 'Delete Quiz',
      content:
          'Are you sure you want to delete this quiz and all of its questions?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirm == true) {
      try {
        await _quizController.deleteQuiz(quizId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete quiz: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final session = AuthService.currentSession;
    final initials = _buildInitials(session?.displayName ?? 'AR');

    return AppShell(
      header: AppTopHeader(
        title: 'AlpenQuiz',
        subtitle: '',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      bottomNavigationBar: _showBottomBar
          ? AppBottomNavigationBar(
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
            )
          : null,
      body: _buildBody(context, colors),
    );
  }

  Widget _buildBody(BuildContext context, ColorsConfig colors) {
    if (_currentNavIndex == 0) {
      return ClientView(
        onPhaseChanged: (phase) {
          setState(() {
            _showBottomBar = phase == ClientPhase.scanning;
          });
        },
      );
    }

    if (_currentNavIndex == 2) {
      return const ProfileScreen();
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: QuizSyncService().isOnline,
          builder: (context, isOnline, child) {
            if (isOnline) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are offline. Changes will be saved locally and synchronized when connection is restored.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ValueListenableBuilder<String?>(
          valueListenable: QuizSyncService().syncError,
          builder: (context, errorMsg, child) {
            if (errorMsg == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orangeAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMsg,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AppSearchField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _currentPage = 1; // Reset pagination when searching
            });
          },
        ),
        const SizedBox(height: 20),
        const AppSectionLabel(eyebrow: 'YOUR COLLECTION', title: 'My Quizzes'),
        const SizedBox(height: 18),
        ValueListenableBuilder<Box<Quiz>>(
          valueListenable: HiveService.quizBox.listenable(),
          builder: (context, box, child) {
            final allQuizzes = _quizController.quizzes;

            // 1. Filter by Search Query
            final filteredQuizzes = allQuizzes.where((quiz) {
              if (_searchQuery.isEmpty) return true;
              return quiz.judul.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
            }).toList();

            if (filteredQuizzes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? 'No quizzes match your search.'
                        : 'No quizzes yet. Create your first quiz!',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colors.mutedText),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // 2. Pagination Logic
            final int limit = _currentPage * _itemsPerPage;
            final displayedQuizzes = filteredQuizzes.take(limit).toList();
            final hasMore = limit < filteredQuizzes.length;

            return Column(
              children: [
                ...displayedQuizzes.map(
                  (quiz) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: QuizCard(
                      quiz: quiz,
                      onHistory: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuizHistorySessionsPage(quiz: quiz),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateQuizPage(editQuiz: quiz),
                          ),
                        );
                      },
                      onDelete: () => _deleteQuiz(quiz.id),
                      onStart: () {
                        if (_quizController.getOwnedQuiz(quiz.id) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You can only start your own quizzes.',
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.of(
                          context,
                        ).pushNamed("/host", arguments: quiz.id);
                      },
                    ),
                  ),
                ),
                if (hasMore || _currentPage > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentPage > 1)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentPage--;
                              });
                            },
                            icon: const Icon(
                              Icons.expand_less_rounded,
                              size: 18,
                            ),
                            label: const Text('Show Less'),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.mutedText,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (hasMore && _currentPage > 1)
                          Container(
                            width: 1,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: colors.outline,
                          ),
                        if (hasMore)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentPage++;
                              });
                            },
                            icon: const Icon(
                              Icons.expand_more_rounded,
                              size: 18,
                            ),
                            label: const Text('Show More'),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.primary,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        CreateQuizCard(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CreateQuizPage()));
          },
        ),
        const SizedBox(height: 12),
      ],
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
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
