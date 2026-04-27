import 'package:flutter/material.dart';

import 'controllers/quiz_controller.dart';
import '../../models/db_models.dart';
import '../../services/auth_service.dart';
import '../../theme/colors_config.dart';
import '../../widgets/layout/app_shell.dart';
import 'widgets/question_form_card.dart';

class CreateQuizPage extends StatefulWidget {
  final Quiz? editQuiz;

  const CreateQuizPage({super.key, this.editQuiz});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _quizController = QuizController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;

  List<Soal> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.editQuiz?.judul ?? '');
    _deskripsiController = TextEditingController(text: widget.editQuiz?.deskripsi ?? '');

    if (widget.editQuiz != null) {
      _questions = _quizController.getQuestionsForQuiz(widget.editQuiz!.id);
    } else {
      _addEmptyQuestion();
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _quizController.dispose();
    super.dispose();
  }

  void _addEmptyQuestion() {
    setState(() {
      _questions.add(
        Soal(
          id: '',
          idQuiz: '',
          teksSoal: '',
          idPilihan: [],
          idJawabanBenar: '',
        ),
      );
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan setidaknya satu soal')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final session = AuthService.currentSession;
      final pembuat = session?.displayName ?? 'Guest User';

      if (widget.editQuiz == null) {
        await _quizController.createQuizWithQuestions(
          _judulController.text,
          _deskripsiController.text,
          pembuat,
          _questions,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kuis berhasil dibuat')),
          );
        }
      } else {
        await _quizController.updateQuizWithQuestions(
          widget.editQuiz!.id,
          _judulController.text,
          _deskripsiController.text,
          pembuat,
          _questions,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kuis berhasil diperbarui')),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan kuis: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.backgroundSoft,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: colors.textOnSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.editQuiz != null ? 'Edit Quiz' : 'Create Quiz',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textOnSurface,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    // Quiz Details Section
                    Text(
                      'QUIZ DETAILS',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.mutedText,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _judulController,
                      validator: (val) => val == null || val.isEmpty ? 'Judul kuis tidak boleh kosong' : null,
                      decoration: InputDecoration(
                        hintText: 'e.g. Science Chapter 3',
                        hintStyle: TextStyle(color: colors.mutedText.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: colors.surfaceLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      style: textTheme.titleMedium?.copyWith(color: colors.textOnSurface, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deskripsiController,
                      validator: (val) => val == null || val.isEmpty ? 'Deskripsi kuis tidak boleh kosong' : null,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter quiz description...',
                        hintStyle: TextStyle(color: colors.mutedText.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: colors.surfaceLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      style: textTheme.bodyMedium?.copyWith(color: colors.textOnSurface),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Questions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Questions',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.textOnSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${_questions.length} QUESTIONS ADDED',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.textOnPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ...List.generate(_questions.length, (index) {
                      return QuestionFormCard(
                        key: ValueKey(_questions[index].hashCode),
                        index: index,
                        initialSoal: _questions[index],
                        onChanged: (updatedSoal) {
                          _questions[index] = updatedSoal;
                        },
                        onDelete: () {
                          setState(() {
                            _questions.removeAt(index);
                          });
                        },
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Add Question Button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: _addEmptyQuestion,
                        icon: const Icon(Icons.add_circle, color: Colors.white),
                        label: const Text(
                          'ADD QUESTION',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.secondary, // Yellow color
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 64), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
