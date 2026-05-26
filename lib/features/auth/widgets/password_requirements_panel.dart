import 'package:flutter/material.dart';

import '../../../theme/colors_config.dart';
import '../password_policy.dart';

class PasswordRequirementsPanel extends StatelessWidget {
  final String password;

  const PasswordRequirementsPanel({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final result = PasswordPolicy.evaluate(password);
    final rules = [
      _RuleState('At least 8 characters', result.minLength),
      _RuleState('Contains lowercase letter', result.hasLowercase),
      _RuleState('Contains uppercase letter', result.hasUppercase),
      _RuleState('Contains number', result.hasDigit),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(rules.length, (index) {
              final fulfilledCount = rules.where((r) => r.isMet).length;
              final isFilled = index < fulfilledCount;
              
              Color progressColor = colors.secondary;
              if (fulfilledCount <= 1) {
                progressColor = Colors.red;
              } else if (fulfilledCount == 2) {
                progressColor = Colors.orange;
              } else if (fulfilledCount == rules.length) {
                progressColor = Colors.green;
              }
              
              return Expanded(
                child: Container(
                  height: 7,
                  margin: EdgeInsets.only(right: index == rules.length - 1 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: isFilled ? progressColor : colors.surfaceHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          ...rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    rule.isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: rule.isMet ? colors.primary : colors.mutedText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rule.label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: rule.isMet ? colors.textOnSurface : colors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Symbols are allowed, but not required.',
            style: textTheme.labelSmall?.copyWith(
              color: colors.mutedText,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleState {
  final String label;
  final bool isMet;

  const _RuleState(this.label, this.isMet);
}
