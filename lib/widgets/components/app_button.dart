import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';

enum ButtonVariant { primary, container, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Color? colorOverride;

  const AppButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
    this.colorOverride,
  });

  factory AppButton.primary({required String label, VoidCallback? onPressed, Color? color}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.primary, colorOverride: color);

  factory AppButton.container({required String label, VoidCallback? onPressed, Color? color}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.container, colorOverride: color);

  factory AppButton.outlined({required String label, VoidCallback? onPressed, Color? color}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.outlined, colorOverride: color);

  factory AppButton.text({required String label, VoidCallback? onPressed, Color? color}) =>
      AppButton._(label: label, onPressed: onPressed, variant: ButtonVariant.text, colorOverride: color);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    final primaryColor = colorOverride ?? colors.primary;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = primaryColor;
        foregroundColor = colors.textOnPrimary;
        break;
      case ButtonVariant.container:
        backgroundColor = colorOverride != null ? colorOverride!.withValues(alpha: 0.1) : colors.primaryContainer;
        foregroundColor = primaryColor;
        break;
      case ButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = primaryColor;
        borderSide = BorderSide(color: primaryColor, width: 1.5);
        break;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = primaryColor;
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