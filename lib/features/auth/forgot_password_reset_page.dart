import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';
import '../../widgets/layout/app_shell.dart';
import 'password_policy.dart';
import 'widgets/password_requirements_panel.dart';

class ForgotPasswordResetPage extends StatefulWidget {
  final String identifier;
  final String otp;

  const ForgotPasswordResetPage({
    super.key,
    required this.identifier,
    required this.otp,
  });

  @override
  State<ForgotPasswordResetPage> createState() => _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleReset() async {
    final passwordError = PasswordPolicy.validate(_passwordController.text);
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Tulis ulang password harus sama.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.resetPasswordWithOtp(
        identifier: widget.identifier,
        otp: widget.otp,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui. Silakan login.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Update password gagal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppShell(
      showHeader: false,
      showBottomNavigation: false,
      bodyPadding: EdgeInsets.zero,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: 8),
            Text(
              'Set New Password',
              style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Langkah 3 dari 3. Buat password baru lalu tulis ulang untuk konfirmasi.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            AppPasswordField(
              label: 'Password Baru',
              hintText: 'Minimal 8 karakter',
              controller: _passwordController,
            ),
            const SizedBox(height: 14),
            PasswordRequirementsPanel(password: _passwordController.text),
            const SizedBox(height: 18),
            AppPasswordField(
              label: 'Tulis Ulang Password',
              hintText: 'Masukkan password yang sama',
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 10),
            if (_confirmPasswordController.text.isNotEmpty)
              Text(
                _confirmPasswordController.text == _passwordController.text
                    ? 'Password cocok.'
                    : 'Password belum sama.',
                style: textTheme.bodyMedium?.copyWith(
                  color: _confirmPasswordController.text == _passwordController.text
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: _isSubmitting ? 'Updating...' : 'Update Password',
              onPressed: _isSubmitting ? null : _handleReset,
            ),
          ],
        ),
      ),
    );
  }
}
