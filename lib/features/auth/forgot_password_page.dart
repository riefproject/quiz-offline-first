import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';
import '../../widgets/layout/app_shell.dart';
import 'forgot_password_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _identifierController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final otp = await AuthService.requestPasswordResetOtp(
        identifier: _identifierController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demo OTP: $otp')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordOtpPage(
            identifier: _identifierController.text.trim(),
          ),
        ),
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Pemulihan akun gagal: $e');
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
              'Recover Account',
              style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Langkah 1 dari 3. Masukkan email atau nomor HP yang terdaftar untuk meminta kode OTP.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Email atau Nomor HP',
              hintText: 'name@example.com / 0812xxxxxxx',
              controller: _identifierController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: _isSubmitting ? 'Sending...' : 'Send OTP Code',
              onPressed: _isSubmitting ? null : _handleContinue,
            ),
          ],
        ),
      ),
    );
  }
}
