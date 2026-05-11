import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'AlpenQuiz',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Versi 1.0.0 (Offline-First)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Aplikasi kuis dengan sinkronisasi pintar ketika internet terhubung.\nCocok dimainkan baik Online maupun Offline di mana saja.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Dibuat dengan ❤️',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
