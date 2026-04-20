import 'package:flutter/material.dart';

import '../../../widgets/components/app_card.dart';
import '../../../theme/colors_config.dart';

class CreateQuizCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateQuizCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AppCard(
        surface: CardSurface.low,
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outline, width: 1.2),
            color: colors.surfaceLowest.withValues(alpha: 0.55),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.32),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create New Quiz',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.textOnSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate a custom quiz from your notes or a specific topic.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.mutedText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}