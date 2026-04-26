import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';

enum ButtonVariant { primary, container, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;

  const AppButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  factory AppButton.primary({required String label, VoidCallback? onPressed}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.primary);

  factory AppButton.container({required String label, VoidCallback? onPressed}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.container);

  factory AppButton.outlined({required String label, VoidCallback? onPressed}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.outlined);

  factory AppButton.text({required String label, VoidCallback? onPressed}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.text);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = colors.primary;
        foregroundColor = colors.textOnPrimary;
        break;
      case ButtonVariant.container:
        backgroundColor = colors.primaryContainer;
        foregroundColor = colors.primary;
        break;
      case ButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.primary;
        borderSide = BorderSide(color: colors.primary, width: 1.5);
        break;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.primary;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: borderSide,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    if (variant == ButtonVariant.text) {
      return TextButton(
        style: buttonStyle,
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return ElevatedButton(
      style: buttonStyle,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class AppFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppFab({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colors.secondary,
      foregroundColor: colors.textOnSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon),
    );
  }
}