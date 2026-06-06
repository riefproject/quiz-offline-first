import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/emailjs_service.dart';
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
      await AuthService.requestPasswordResetOtp(
        identifier: _identifierController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP code has been sent to your email.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordOtpPage(
            identifier: _identifierController.text.trim(),
          ),
        ),
      );
    } on EmailJsException catch (e) {
      _showMessage(e.message);
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Account recovery failed: $e');
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
              'Step 1 of 3. Enter your registered email address to request an OTP code.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Email Address',
              hintText: 'name@example.com',
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
