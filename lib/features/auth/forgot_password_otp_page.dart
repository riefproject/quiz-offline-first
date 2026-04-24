import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';
import '../../widgets/layout/app_shell.dart';
import 'forgot_password_reset_page.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  final String identifier;

  const ForgotPasswordOtpPage({
    super.key,
    required this.identifier,
  });

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final _otpController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_otpController.text.trim().length != 8) {
        throw AuthException('Kode OTP harus 8 digit.');
      }
      await AuthService.verifyPasswordResetOtp(
        identifier: widget.identifier,
        otp: _otpController.text,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordResetPage(
            identifier: widget.identifier,
            otp: _otpController.text.trim(),
          ),
        ),
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Verifikasi OTP gagal: $e');
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
              'Enter OTP',
              style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Langkah 2 dari 3. Masukkan 8 digit kode OTP untuk ${widget.identifier}.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: '8 Digit OTP',
              hintText: '12345678',
              controller: _otpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Text(
              'OTP saat ini masih placeholder untuk demo alur UI.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: _isSubmitting ? 'Verifying...' : 'Verify OTP',
              onPressed: _isSubmitting ? null : _handleContinue,
            ),
          ],
        ),
      ),
    );
  }
}
