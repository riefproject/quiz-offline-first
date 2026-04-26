import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/auth_gate.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/guest_join_page.dart';
import 'features/auth/login.dart';
import 'features/auth/register_page.dart';
import 'features/quiz/client/client_view.dart';
import 'features/quiz/host/host_view.dart';
import 'features/quiz/role_choice_page.dart';
import 'services/hive_service.dart';
import 'services/mongodb_service.dart';
import 'theme/theme_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await HiveService.init();
  await MongoDatabase.tryConnect();

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kahoof!',
      theme: ThemeConfig.lightTheme,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/forgot-password': (_) => const ForgotPasswordPage(),
        '/guest': (_) => GuestJoinPage(),
        '/app': (_) => const AuthGate(),
        '/play': (_) => const RoleChoicePage(),
        '/host': (_) => const HostView(),
        '/client': (_) => const ClientView(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
