import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../services/quiz_sync_service.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/db_models.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/layout/app_bottom_navigation.dart';
import '../../widgets/layout/app_shell.dart';
import '../../widgets/layout/app_top_header.dart';
import '../../theme/colors_config.dart';
import '../../widgets/components/app_confirm_modal.dart';
import 'widgets/create_quiz_card.dart';
import 'widgets/quiz_card.dart';
import 'create_quiz_page.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  int _currentNavIndex = 1;
  final _quizController = QuizController();
  
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
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _deleteQuiz(String quizId) async {
    final confirm = await AppConfirmModal.show(
      context,
      title: 'Hapus Kuis',
      content: 'Apakah Anda yakin ingin menghapus kuis ini beserta seluruh pertanyaannya?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirm == true) {
      await _quizController.deleteQuiz(quizId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kuis berhasil dihapus')),
        );
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
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda sedang offline. Perubahan akan disimpan secara lokal dan disinkronisasi saat koneksi pulih.',
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
                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: Colors.orangeAccent, size: 20),
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
          const AppSectionLabel(
            eyebrow: 'YOUR COLLECTION',
            title: 'My Quizzes',
          ),
          const SizedBox(height: 18),
          ValueListenableBuilder<Box<Quiz>>(
            valueListenable: HiveService.quizBox.listenable(),
            builder: (context, box, _) {
              final allQuizzes = box.values.toList();
              
              // 1. Filter by Search Query
              final filteredQuizzes = allQuizzes.where((quiz) {
                if (_searchQuery.isEmpty) return true;
                return quiz.judul.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredQuizzes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      _searchQuery.isNotEmpty 
                          ? 'Tidak ada kuis yang cocok dengan pencarian Anda.' 
                          : 'Belum ada kuis. Buat kuis pertama Anda!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.mutedText,
                      ),
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
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CreateQuizPage(editQuiz: quiz)),
                          );
                        },
                        onDelete: () => _deleteQuiz(quiz.id),
                        onStart: () {},
                      ),
                    ),
                  ),
                  if (hasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentPage++;
                          });
                        },
                        icon: const Icon(Icons.expand_more_rounded),
                        label: const Text('Tampilkan Lebih Banyak'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.primary,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          CreateQuizCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateQuizPage()),
              );
            },
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
