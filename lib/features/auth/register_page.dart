import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';
import '../../services/auth_service.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';
import '../../widgets/layout/app_shell.dart';
import 'password_policy.dart';
import 'widgets/password_requirements_panel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleRegister() async {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (_emailController.text.isNotEmpty && !emailRegex.hasMatch(_emailController.text)) {
      _showMessage('Please enter a valid email address (e.g. name@example.com).');
      return;
    }
    
    final phoneRegex = RegExp(r'^(\+62|62|08)[0-9]{8,13}$');
    if (_phoneController.text.isNotEmpty && !phoneRegex.hasMatch(_phoneController.text)) {
      _showMessage('Phone number must be a valid Indonesian format (+62, 62, or 08).');
      return;
    }

    final passwordError = PasswordPolicy.validate(_passwordController.text);
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.register(
        namaLengkap: _nameController.text,
        email: _emailController.text,
        nomorHp: _phoneController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account successfully created.')),
      );
      Navigator.of(context).pushReplacementNamed('/app');
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Registration failed: $e');
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
    final colors = Theme.of(context).extension<ColorsConfig>()!;
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
              'Create Account',
              style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter at least an email or phone number. Both can be used for account recovery. An active internet connection is required to register.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Full Name',
              hintText: 'Ariana Rizki',
              controller: _nameController,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Email',
              hintText: 'name@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Phone Number',
              hintText: '081234567890',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            AppPasswordField(
              controller: _passwordController,
              hintText: 'Minimum 8 characters',
            ),
            const SizedBox(height: 14),
            PasswordRequirementsPanel(password: _passwordController.text),
            const SizedBox(height: 18),
            AppPasswordField(
              label: 'Retype Password',
              hintText: 'Enter the same password',
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 10),
            if (_confirmPasswordController.text.isNotEmpty)
              Text(
                _confirmPasswordController.text == _passwordController.text
                    ? 'Passwords match.'
                    : 'Passwords do not match.',
                style: textTheme.bodyMedium?.copyWith(
                  color: _confirmPasswordController.text == _passwordController.text
                      ? colors.primary
                      : Colors.red,
                ),
              ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: _isSubmitting ? 'Creating...' : 'Create Account',
              onPressed: _isSubmitting ? null : _handleRegister,
            ),
            const SizedBox(height: 14),
            AppButton.text(
              label: 'Back to Login',
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
