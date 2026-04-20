import 'package:flutter/material.dart';
import '../theme/colors_config.dart';

enum ButtonVariant { primary, container, outlined, text }

class PulseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;

  const PulseButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  factory PulseButton.primary({required String label, VoidCallback? onPressed}) =>
      PulseButton._(label: label, onPressed: onPressed, variant: ButtonVariant.primary);

  factory PulseButton.container({required String label, VoidCallback? onPressed}) =>
      PulseButton._(label: label, onPressed: onPressed, variant: ButtonVariant.container);

  factory PulseButton.outlined({required String label, VoidCallback? onPressed}) =>
      PulseButton._(label: label, onPressed: onPressed, variant: ButtonVariant.outlined);

  factory PulseButton.text({required String label, VoidCallback? onPressed}) =>
      PulseButton._(label: label, onPressed: onPressed, variant: ButtonVariant.text);

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
        borderRadius: BorderRadius.circular(100),
        side: borderSide,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
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

class PulseFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const PulseFAB({super.key, required this.icon, required this.onPressed});

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