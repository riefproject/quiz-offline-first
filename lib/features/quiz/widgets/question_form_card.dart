import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _isSavingImage = false;
  String? _photoUrl;
  String? _localPhotoPath;

  @override
  void initState() {
    super.initState();
    _teksSoalController = TextEditingController(
      text: widget.initialSoal.teksSoal,
    );
    _pilihanControllers = widget.initialSoal.idPilihan
        .map((p) => TextEditingController(text: p))
        .toList();
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
    _photoUrl = widget.initialSoal.fotoSoal;
    _localPhotoPath = widget.initialSoal.localFotoPath;

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
      fotoSoal: _photoUrl,
      localFotoPath: _localPhotoPath,
    );
    widget.onChanged(updatedSoal);
  }

  Future<void> _pickImageOfflineFirst() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        setState(() {
          _isSavingImage = true;
        });

        final appDir = await getApplicationDocumentsDirectory();
        final dotIndex = pickedFile.name.lastIndexOf('.');
        final extension = dotIndex == -1
            ? ''
            : pickedFile.name.substring(dotIndex + 1).toLowerCase();
        final safeExtension = extension.isEmpty ? 'jpg' : extension;
        final fileName =
            'quiz_img_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
        final savedImage = await File(
          pickedFile.path,
        ).copy('${appDir.path}/$fileName');

        if (!mounted) return;

        setState(() {
          _localPhotoPath = savedImage.path;
          _photoUrl = null;
          _isSavingImage = false;
        });
        _notifyChange();
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSavingImage = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save image: $e')));
        }
      }
    }
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
                  Icon(
                    Icons.drag_indicator_rounded,
                    color: colors.mutedText.withValues(alpha: 0.5),
                    size: 20,
                  ),
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
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colors.mutedText,
                  size: 22,
                ),
                onPressed: widget.onDelete,
                tooltip: 'Delete Question',
                visualDensity: VisualDensity.compact,
              ),
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
              hintStyle: TextStyle(
                color: colors.mutedText.withValues(alpha: 0.6),
              ),
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
          const SizedBox(height: 12),
          if (_isSavingImage)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: colors.primary),
              ),
            )
          else if ((_localPhotoPath != null && _localPhotoPath!.isNotEmpty) || (_photoUrl != null && _photoUrl!.isNotEmpty))
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _localPhotoPath != null && _localPhotoPath!.isNotEmpty
                      ? Image.file(
                          File(_localPhotoPath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Image.network(
                            _photoUrl ?? '',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image))),
                          ),
                        )
                      : Image.network(
                          _photoUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _photoUrl = null;
                        _localPhotoPath = null;
                      });
                      _notifyChange();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickImageOfflineFirst,
                icon: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: colors.primary,
                  size: 20,
                ),
                label: Text(
                  'Add Photo',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                    color: colors.surfaceLow.withValues(
                      alpha: isCorrect ? 1.0 : 0.6,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect
                          ? colors.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
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
                            hintStyle: TextStyle(
                              color: colors.mutedText.withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            errorStyle: const TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textOnSurface,
                            fontWeight: isCorrect
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      if (_pilihanControllers.length > 2)
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.mutedText.withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            setState(() {
                              _pilihanControllers.removeAt(index).dispose();
                              if (_correctAnswerId == index.toString()) {
                                _correctAnswerId = '0';
                              } else if (int.parse(_correctAnswerId) > index) {
                                _correctAnswerId =
                                    (int.parse(_correctAnswerId) - 1)
                                        .toString();
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
                          color: isCorrect
                              ? colors.secondary
                              : Colors.transparent,
                          border: isCorrect
                              ? null
                              : Border.all(
                                  color: colors.mutedText.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1.5,
                                ),
                        ),
                        child: isCorrect
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_pilihanControllers.length < 4)
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
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: colors.primary,
                  size: 20,
                ),
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
