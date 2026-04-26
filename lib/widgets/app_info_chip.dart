import 'package:flutter/material.dart';

import '../theme/colors_config.dart';

class AppInfoChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color? tintColor;
  /// If true, renders a subtle green tint (for "Synced" status)
  final bool isSynced;

  const AppInfoChip({
    super.key,
    this.icon,
    required this.label,
    this.tintColor,
    this.isSynced = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textColor = tintColor ?? colors.mutedText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced ? colors.tertiary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSynced
              ? const Color(0xFFA5D6A7)
              : colors.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}