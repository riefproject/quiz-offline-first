// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:py_4/features/quiz/quiz_list_page.dart';
import 'package:py_4/theme/theme_config.dart';

void main() {
  testWidgets('shows quiz list layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ThemeConfig.lightTheme, home: const QuizListPage()),
    );
    await tester.pump();

    expect(find.text('AlpenQuiz'), findsOneWidget);
    expect(find.text('My Quizzes'), findsOneWidget);
    expect(find.text('Molecular Biology Basics'), findsOneWidget);
    expect(find.text('Quizzes'), findsWidgets);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Create New Quiz'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create New Quiz'), findsOneWidget);
  });
}
