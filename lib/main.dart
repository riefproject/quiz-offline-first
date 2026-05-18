import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/auth_gate.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/login.dart';
import 'features/auth/register_page.dart';
import 'features/quiz/client/client_guest_view.dart';
import 'features/quiz/host/host_view.dart';
import 'features/quiz/role_choice_page.dart';
import 'services/auth_service.dart';
import 'services/hive_service.dart';
import 'services/logger.dart';
import 'services/mongodb_service.dart';
import 'theme/theme_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mengunci orientasi aplikasi menjadi Portrait saja
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: '.env');
  await initLogger();
  await HiveService.init();
  
  // Inisialisasi SharedPreferences untuk session Auth
  final prefs = await SharedPreferences.getInstance();
  AuthService.init(prefs);
  
  await MongoDatabase.tryConnect();

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlpenQuiz',
      theme: ThemeConfig.lightTheme,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/forgot-password': (_) => const ForgotPasswordPage(),
        '/app': (_) => const AuthGate(),
        '/play': (_) => const RoleChoicePage(),
        '/client': (_) => const ClientGuestView(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/host') {
          final quizId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HostView(quizId: quizId),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
