import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isValid;
  final Widget? prefix;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.errorText,
    this.isValid = false,
    this.prefix,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
          style: textTheme.labelSmall?.copyWith(color: colors.textOnSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          focusNode: _focusNode,
          decoration: _buildInputDecoration(
            colors, 
            widget.hintText,
            errorText: widget.errorText,
            isValid: widget.isValid,
            isFocused: _focusNode.hasFocus,
            prefix: widget.prefix,
          ),
          style: TextStyle(color: colors.textOnSurface, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class AppPasswordField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isValid;
  final FocusNode? focusNode;

  const AppPasswordField({
    super.key,
    this.label = 'Password',
    this.hintText = '••••••••',
    this.controller,
    this.onChanged,
    this.errorText,
    this.isValid = false,
    this.focusNode,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  void _onFocusChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

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
          style: textTheme.labelSmall?.copyWith(color: colors.textOnSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          focusNode: _focusNode,
          decoration: _buildInputDecoration(
            colors, 
            widget.hintText,
            errorText: widget.errorText,
            isValid: widget.isValid,
            isFocused: _focusNode.hasFocus,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: colors.textOnSurface.withValues(alpha: 0.5),
              ),
              onPressed: _toggleVisibility,
              splashRadius: 20,
            ),
          ),
          style: TextStyle(
            color: colors.textOnSurface,
            fontWeight: FontWeight.w500,
            letterSpacing: _obscureText ? 2.0 : 0.0,
          ),
        ),
      ],
    );
  }
}

InputDecoration _buildInputDecoration(
  ColorsConfig colors, 
  String hintText, {
  String? errorText,
  bool isValid = false,
  bool isFocused = false,
  Widget? prefix,
}) {
  Color? focusedBorderColor = colors.primary;
  if (errorText != null) {
    focusedBorderColor = Colors.red;
  } else if (isValid && isFocused) {
    focusedBorderColor = Colors.green;
  }

  Color? enabledBorderColor = Colors.transparent;
  if (errorText != null) {
    enabledBorderColor = Colors.red;
  }

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: colors.textOnSurface.withValues(alpha: 0.3), letterSpacing: 0),
    errorText: errorText,
    prefixIcon: prefix,
    filled: true,
    fillColor: colors.surfaceLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: enabledBorderColor == Colors.transparent 
          ? BorderSide.none 
          : BorderSide(color: enabledBorderColor, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}