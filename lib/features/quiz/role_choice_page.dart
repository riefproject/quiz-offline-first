import 'package:flutter/material.dart';
import '../../theme/colors_config.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_card.dart';

class RoleChoicePage extends StatelessWidget {
  const RoleChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'AlpenQuiz',
                      style: textTheme.headlineLarge?.copyWith(
                        color: colors.textOnPrimary,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Play Live Quiz',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textOnSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your role to start a real-time quiz session over Bluetooth.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.mutedText,
                  ),
                ),
                const SizedBox(height: 32),
                AppCard(
                  surface: CardSurface.low,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.cast_rounded, size: 40, color: colors.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Host',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.textOnSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a quiz session and broadcast questions. You control the pace.',
                        style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
                      ),
                      const SizedBox(height: 16),
                      AppButton.primary(
                        label: 'Host a Game',
                        onPressed: () => Navigator.of(context).pushNamed('/host'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  surface: CardSurface.low,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.phonelink_rounded, size: 40, color: colors.secondary),
                      const SizedBox(height: 12),
                      Text(
                        'Client',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.textOnSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scan for nearby quiz sessions and answer questions in real time.',
                        style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
                      ),
                      const SizedBox(height: 16),
                      AppButton.outlined(
                        label: 'Join a Game',
                        onPressed: () => Navigator.of(context).pushNamed('/client'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back',
                    style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
