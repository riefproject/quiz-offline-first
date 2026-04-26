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
            color: colors.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.08 * 11, // 0.08em
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: textTheme.headlineLarge?.copyWith(
            color: colors.textOnSurface,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: -0.3,
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