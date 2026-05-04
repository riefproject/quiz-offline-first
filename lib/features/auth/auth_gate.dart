import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../onboarding/onboarding_page.dart';
import '../quiz/quiz_list_page.dart';
import '../quiz/user/user_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthService.currentSession;
    if (session == null) {
      return const OnboardingPage();
    }
    if (session.isGuest) {
      return const UserView();
    }
    return const QuizListPage();
  }
}
