import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:py_4/features/auth/login.dart';
import 'package:py_4/features/quiz/quiz_list_page.dart';

// Impor dari core module
import 'theme/theme_config.dart';
import 'theme/colors_config.dart';

// Impor dari reusable widgets module
import 'widgets/components/app_button.dart';
import 'widgets/components/app_card.dart';
import 'widgets/components/app_input.dart';
import 'services/mongodb_service.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Local Database Initiation (Hive - Offline First)
  await HiveService.init();

  // Cloud Database Initiation (MongoDB Sync Base)
  await MongoDatabase.connect();

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Quiz',
      theme: ThemeConfig.lightTheme,
      home: const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class StyleGuideShowcasePage extends StatelessWidget {
  const StyleGuideShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Intelligent Quiz', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: colors.surfaceLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: AppFab(
        icon: Icons.bolt,
        onPressed: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Design System Guidelines', style: textTheme.headlineLarge?.copyWith(color: colors.primary)),
          const SizedBox(height: 8),
          Text(
            'A comprehensive framework for building high-end, editorial gamified experiences.',
            style: textTheme.bodyLarge,
          ),
          
          const _SectionHeader('02. Typography'),
          Text('Intelligent', style: textTheme.displayLarge),
          const SizedBox(height: 16),
          Text('The Modern Quiz Experience', style: textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text('SYSTEM ARCHITECTURE', style: textTheme.labelSmall),

          const _SectionHeader('03. Buttons'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              AppButton.primary(label: 'Primary Action', onPressed: () {}),
              AppButton.container(label: 'Container', onPressed: () {}),
              AppButton.outlined(label: 'Outlined', onPressed: () {}),
              AppButton.text(label: 'Text Button', onPressed: () {}),
            ],
          ),

          const _SectionHeader('04. Controls'),
          const AppTextField(
            label: 'Email Address',
            hintText: 'name@example.com',
          ),
          const SizedBox(height: 16),
          AppCard(
            surface: CardSurface.low,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_none, color: colors.primary),
                    const SizedBox(width: 8),
                    Text('Smart Notifications', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
                Switch(
                  value: true, 
                  onChanged: (v){},
                  activeColor: colors.surfaceLowest,
                  activeTrackColor: colors.primary,
                )
              ],
            ),
          ),

          const _SectionHeader('05. Cards'),
          AppCard(
            surface: CardSurface.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GLOBAL STREAK', style: textTheme.labelSmall?.copyWith(color: colors.textOnPrimary.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text('24 Days', style: textTheme.headlineLarge?.copyWith(color: colors.textOnPrimary)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.bar_chart, color: colors.textOnPrimary),
                    Icon(Icons.trending_up, color: colors.textOnPrimary.withOpacity(0.5)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 60), 
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}