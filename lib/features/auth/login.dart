import 'package:flutter/material.dart';
import '../../widgets/layout/app_shell.dart';
import '../../theme/colors_config.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'KAHOOF!',
                    style: textTheme.headlineLarge?.copyWith(
                      color: colors.textOnPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz smarter, compete together',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textOnSurface,
                ),
              ),
              const SizedBox(height: 48),
              const AppTextField(
                label: 'Email Address',
                hintText: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const AppPasswordField(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password routing
                  },
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
              const SizedBox(height: 32),
              AppButton.primary(
                label: 'Log In',
                onPressed: () {
                  // TODO: Implement login logic
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Doesn't have an account? ",
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textOnSurface.withValues(alpha:0.8),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement register routing
                    },
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
                  Expanded(child: Divider(color: colors.textOnSurface.withValues(alpha:0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.textOnSurface.withValues(alpha:0.5),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.textOnSurface.withValues(alpha:0.1))),
                ],
              ),
              const SizedBox(height: 32),
              AppButton.outlined(
                label: 'Join as a Guest',
                onPressed: () {
                  // TODO: Implement guest logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}