import 'package:flutter/material.dart';

import '../theme/colors_config.dart';

class AppSectionLabel extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const AppSectionLabel({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: textTheme.labelSmall?.copyWith(
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: textTheme.headlineLarge?.copyWith(
            color: colors.textOnSurface,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.mutedText,
            ),
          ),
        ],
      ],
    );
  }
}