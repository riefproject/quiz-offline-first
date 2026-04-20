// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:py_4/main.dart';

void main() {
  testWidgets('shows quiz list layout', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizApp());
    await tester.pumpAndSettle();

    expect(find.text('Intelligent Pulse'), findsOneWidget);
    expect(find.text('My Quizzes'), findsOneWidget);
    expect(find.text('Molecular Biology Basics'), findsOneWidget);
    expect(find.text('Quizzes'), findsWidgets);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('Create New Quiz'), findsOneWidget);
  });
}
