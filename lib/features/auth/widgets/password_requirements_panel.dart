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
      _RuleState('Minimal 8 karakter', result.minLength),
      _RuleState('Ada huruf kecil', result.hasLowercase),
      _RuleState('Ada huruf besar', result.hasUppercase),
      _RuleState('Ada angka', result.hasDigit),
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
              final fulfilled = rules[index].isMet;
              return Expanded(
                child: Container(
                  height: 7,
                  margin: EdgeInsets.only(right: index == rules.length - 1 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: fulfilled ? colors.secondary : colors.surfaceHigh,
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
            'Simbol boleh dipakai, tapi tidak wajib.',
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
