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
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: surface == CardSurface.lowest
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: child,
    );
  }
}