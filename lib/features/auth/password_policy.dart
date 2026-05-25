class PasswordPolicyResult {
  final bool minLength;
  final bool hasLowercase;
  final bool hasUppercase;
  final bool hasDigit;

  const PasswordPolicyResult({
    required this.minLength,
    required this.hasLowercase,
    required this.hasUppercase,
    required this.hasDigit,
  });

  bool get isValid => minLength && hasLowercase && hasUppercase && hasDigit;
}

class PasswordPolicy {
  static PasswordPolicyResult evaluate(String value) {
    return PasswordPolicyResult(
      minLength: value.length >= 8,
      hasLowercase: RegExp(r'[a-z]').hasMatch(value),
      hasUppercase: RegExp(r'[A-Z]').hasMatch(value),
      hasDigit: RegExp(r'\d').hasMatch(value),
    );
  }

  static String? validate(String value) {
    final result = evaluate(value);
    if (result.isValid) return null;
    return 'Password must be at least 8 characters long and contain lowercase letters, uppercase letters, and numbers.';
  }
}
