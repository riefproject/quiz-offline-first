import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';
import '../../widgets/layout/app_shell.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.login(
        identifier: _identifierController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/app');
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Login gagal: $e');
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
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.4],
        colors: [
          colors.tertiary.withValues(alpha: 0.15),
          colors.surfaceLowest,
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Kahoof!',
                    style: textTheme.headlineLarge?.copyWith(
                      color: colors.textOnPrimary,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Masuk untuk membuat atau mengikuti kuis. Jika belum punya akun, daftar dengan email atau nomor HP untuk pemulihan akun.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textOnSurface,
                ),
              ),
              const SizedBox(height: 40),
              AppTextField(
                label: 'Email atau Nomor HP',
                hintText: 'name@example.com / 0812xxxxxxx',
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              AppPasswordField(
                controller: _passwordController,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pushNamed('/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot your password?',
                    style: textTheme.labelSmall?.copyWith(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AppButton.primary(
                label: _isSubmitting ? 'Signing In...' : 'Log In',
                onPressed: _isSubmitting ? null : _handleLogin,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Doesn't have an account? ",
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textOnSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pushNamed('/register'),
                    child: Text(
                      'Register',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider(color: colors.textOnSurface.withValues(alpha: 0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.textOnSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.textOnSurface.withValues(alpha: 0.1))),
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 12),
              AppButton.outlined(
                label: 'Join as a Guest',
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pushNamed('/guest'),
              ),
              const SizedBox(height: 12),
              AppButton.text(
                label: 'Play Live Quiz',
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pushNamed('/play'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
