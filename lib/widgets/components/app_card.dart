import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';

enum CardSurface { lowest, low, high, primary }

class AppCard extends StatelessWidget {
  final Widget child;
  final CardSurface surface;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.surface = CardSurface.lowest,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    Color bgColor;
    switch (surface) {
      case CardSurface.lowest:
        bgColor = colors.surfaceLowest;
        break;
      case CardSurface.low:
        bgColor = colors.surfaceLow;
        break;
      case CardSurface.high:
        bgColor = colors.surfaceHigh;
        break;
      case CardSurface.primary:
        bgColor = colors.primary;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceLowest, // Always white
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline),
      ),
      child: child,
    );
  }
}