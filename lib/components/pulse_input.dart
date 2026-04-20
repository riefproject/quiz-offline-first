import 'package:flutter/material.dart';
import '../../theme/colors_config.dart';

/// Input teks standar (Email, Username, dll)
class PulseTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const PulseTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: colors.textOnSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _buildInputDecoration(colors, hintText),
          style: TextStyle(color: colors.textOnSurface, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/// Input khusus Password.
/// Diisolasi menjadi StatefulWidget agar toggle visibilitas TIDAK memicu 
/// rebuild pada halaman utama (Parent Widget). Ini adalah optimasi performa.
class PulsePasswordField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;

  const PulsePasswordField({
    super.key,
    this.label = 'Password',
    this.hintText = '••••••••',
    this.controller,
  });

  @override
  State<PulsePasswordField> createState() => _PulsePasswordFieldState();
}

class _PulsePasswordFieldState extends State<PulsePasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: textTheme.labelSmall?.copyWith(color: colors.textOnSurface.withValues(alpha:0.6)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: _buildInputDecoration(colors, widget.hintText).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: colors.textOnSurface.withValues(alpha:0.5),
              ),
              onPressed: _toggleVisibility,
              splashRadius: 20,
            ),
          ),
          style: TextStyle(color: colors.textOnSurface, fontWeight: FontWeight.w500, letterSpacing: _obscureText ? 2.0 : 0.0),
        ),
      ],
    );
  }
}

/// Helper method agar dekorasi tetap DRY (Don't Repeat Yourself)
InputDecoration _buildInputDecoration(ColorsConfig colors, String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: colors.textOnSurface.withValues(alpha:0.3), letterSpacing: 0),
    filled: true,
    fillColor: colors.surfaceLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    ),
  );
}