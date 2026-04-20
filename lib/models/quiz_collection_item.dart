import 'package:flutter/material.dart';

class QuizCollectionItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final int questionCount;
  final int estimatedMinutes;

  const QuizCollectionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.questionCount,
    required this.estimatedMinutes,
  });

  static const List<QuizCollectionItem> samples = [
    QuizCollectionItem(
      title: 'Molecular Biology Basics',
      description: 'Master the fundamentals of DNA replication, protein synthesis, and cellular mechanisms.',
      icon: Icons.science_rounded,
      accentColor: Color(0xFFF0B74F),
      questionCount: 24,
      estimatedMinutes: 15,
    ),
    QuizCollectionItem(
      title: 'The Industrial Revolution',
      description: 'Key inventions and social changes that shaped the modern manufacturing world.',
      icon: Icons.history_edu_rounded,
      accentColor: Color(0xFFA96CF1),
      questionCount: 18,
      estimatedMinutes: 10,
    ),
    QuizCollectionItem(
      title: 'Advanced Calculus II',
      description: 'Multivariable integration and vector analysis for engineering students.',
      icon: Icons.functions_rounded,
      accentColor: Color(0xFFF07F75),
      questionCount: 12,
      estimatedMinutes: 20,
    ),
  ];
}