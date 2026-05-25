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
          _buildSectionHeader(context, 'Getting Started'),
          _buildFaqItem(
            context,
            'How do I start an offline quiz?',
            'To start an offline quiz, make sure you have synchronized the quiz data at least once using the Sync button on your profile, or downloaded the quiz questions. Once done, you can play completely offline without any interruptions.',
          ),
          _buildFaqItem(
            context,
            'Will I lose my data if I change devices?',
            'As long as you are registered and have successfully synchronized your progress to the Cloud using an internet connection, your data will be safely stored and can be retrieved on any device.',
          ),
          _buildFaqItem(
            context,
            'How do I host a multiplayer game offline?',
            'You can host a game on your local network (LAN or Wi-Fi Hotspot) by selecting "Host a Game" and choosing a quiz. Other players on the same network can join your session in real time without any internet connection.',
          ),
          _buildFaqItem(
            context,
            'How do I join a game as a client?',
            'Ensure you are connected to the same local network as the Host. Go to the "Play Live Quiz" section, select "Join a Game", and your device will automatically discover and connect to the active session.',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Synchronization'),
          _buildFaqItem(
            context,
            'Why is the Sync button important?',
            'The Sync button allows the app to merge your offline progress to the server and download new or updated quizzes from the Cloud backend. This ensures your progress is never lost.',
          ),
          _buildFaqItem(
            context,
            'How often should I sync?',
            'We recommend syncing your data whenever you have a stable internet connection, especially after completing multiple quizzes offline, to ensure your latest progress is backed up.',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Account & Security'),
          _buildFaqItem(
            context,
            'Can I register offline?',
            'No, registration requires an active internet connection to ensure your account details are securely created and validated on our servers.',
          ),
          _buildFaqItem(
            context,
            'How is my password stored?',
            'Your password is encrypted using industry-standard hashing algorithms before it is saved. We take your security seriously and never store passwords in plain text.',
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
