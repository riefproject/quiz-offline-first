import 'package:flutter/material.dart';

import '../../../models/db_models.dart';
import '../../../theme/colors_config.dart';

class QuestionFormCard extends StatefulWidget {
  final Soal initialSoal;
  final ValueChanged<Soal> onChanged;
  final VoidCallback onDelete;
  final int index;

  const QuestionFormCard({
    super.key,
    required this.initialSoal,
    required this.onChanged,
    required this.onDelete,
    required this.index,
  });

  @override
  State<QuestionFormCard> createState() => _QuestionFormCardState();
}

class _QuestionFormCardState extends State<QuestionFormCard> {
  late TextEditingController _teksSoalController;
  late List<TextEditingController> _pilihanControllers;
  late String _correctAnswerId;

  @override
  void initState() {
    super.initState();
    _teksSoalController = TextEditingController(text: widget.initialSoal.teksSoal);
    _pilihanControllers = widget.initialSoal.idPilihan.map((p) => TextEditingController(text: p)).toList();
    if (_pilihanControllers.isEmpty) {
      _pilihanControllers.addAll([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    }
    _correctAnswerId = widget.initialSoal.idJawabanBenar.isNotEmpty 
        ? widget.initialSoal.idJawabanBenar 
        : '0';

    _teksSoalController.addListener(_notifyChange);
    for (var c in _pilihanControllers) {
      c.addListener(_notifyChange);
    }
  }

  @override
  void dispose() {
    _teksSoalController.dispose();
    for (var c in _pilihanControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChange() {
    final updatedSoal = widget.initialSoal.copyWith(
      teksSoal: _teksSoalController.text,
      idPilihan: _pilihanControllers.map((c) => c.text).toList(),
      idJawabanBenar: _correctAnswerId,
    );
    widget.onChanged(updatedSoal);
  }

  String _getLetter(int index) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    if (index < letters.length) return letters[index];
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.surfaceLow, width: 2),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.drag_indicator_rounded, color: colors.mutedText.withValues(alpha: 0.5), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'QUESTION ${(widget.index + 1).toString().padLeft(2, '0')}',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.mutedText,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: colors.mutedText, size: 22),
                onPressed: widget.onDelete,
                tooltip: 'Delete Question',
                visualDensity: VisualDensity.compact,
              )
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _teksSoalController,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Pertanyaan tidak boleh kosong';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter your question here...',
              hintStyle: TextStyle(color: colors.mutedText.withValues(alpha: 0.6)),
              filled: true,
              fillColor: colors.surfaceLow,
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            style: textTheme.bodyLarge?.copyWith(color: colors.textOnSurface),
            maxLines: 3,
            minLines: 2,
          ),
          const SizedBox(height: 16),
          ...List.generate(_pilihanControllers.length, (index) {
            final isCorrect = _correctAnswerId == index.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _correctAnswerId = index.toString();
                  });
                  _notifyChange();
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceLow.withValues(alpha: isCorrect ? 1.0 : 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect ? colors.primary.withValues(alpha: 0.3) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _getLetter(index),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _pilihanControllers[index],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Pilihan tidak boleh kosong';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Add option...',
                            hintStyle: TextStyle(color: colors.mutedText.withValues(alpha: 0.5)),
                            border: InputBorder.none,
                            errorStyle: const TextStyle(color: Colors.redAccent),
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textOnSurface,
                            fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_pilihanControllers.length > 2)
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 18, color: colors.mutedText.withValues(alpha: 0.5)),
                          onPressed: () {
                            setState(() {
                              _pilihanControllers.removeAt(index).dispose();
                              if (_correctAnswerId == index.toString()) {
                                _correctAnswerId = '0';
                              } else if (int.parse(_correctAnswerId) > index) {
                                _correctAnswerId = (int.parse(_correctAnswerId) - 1).toString();
                              }
                            });
                            _notifyChange();
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      const SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCorrect ? const Color(0xFF8B6B2B) : Colors.transparent,
                          border: isCorrect ? null : Border.all(color: colors.mutedText.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: isCorrect
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  final newController = TextEditingController();
                  newController.addListener(_notifyChange);
                  _pilihanControllers.add(newController);
                });
                _notifyChange();
              },
              icon: Icon(Icons.add_circle_outline_rounded, color: colors.primary, size: 20),
              label: Text(
                'Add Option',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
