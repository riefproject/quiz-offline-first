import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial & FAQ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSectionHeader(context, 'Gameplay'),
          _buildFaqItem(
            context,
            'How do I play offline?',
            'Create your own quizzes or sync them from the cloud once. After that, you can play them anytime without an internet connection.',
          ),
          _buildFaqItem(
            context,
            'How do I play with friends?',
            'Connect to the same Wi-Fi or Mobile Hotspot. One person selects "Host a Game", and the others select "Join a Game". No internet needed.',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Data & Sync'),
          _buildFaqItem(
            context,
            'When do I need internet?',
            'Internet is only required for registering, logging in, or syncing your local progress to the cloud. All gameplay is 100% offline.',
          ),
          _buildFaqItem(
            context,
            'How do I backup my progress?',
            'The app automatically syncs your progress in the background whenever you are connected to the internet. You can also tap the sync status chip on any quiz card to manually trigger a sync.',
          ),
          _buildFaqItem(
            context,
            'How do I share results offline?',
            'You can use the built-in QR Code feature to transfer quiz results instantly between devices without any internet connection.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.02),
          iconColor: Theme.of(context).colorScheme.primary,
          collapsedIconColor: Colors.grey.shade600,
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                answer,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
