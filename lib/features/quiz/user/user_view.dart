import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../widgets/components/app_button.dart';
import '../../../widgets/components/app_card.dart';
import '../../../widgets/layout/app_shell.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthService.currentSession;
    final textTheme = Theme.of(context).textTheme;

    return AppShell(
      showBottomNavigation: false,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest Lobby', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              Text(
                session?.displayName ?? 'Guest',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        children: [
          AppCard(
            surface: CardSurface.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('READY TO JOIN', style: textTheme.labelSmall?.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  session?.joinCode?.isNotEmpty == true
                      ? 'Session ${session!.joinCode}'
                      : 'Waiting for broadcast selection',
                  style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  'Guest mode hanya dipakai untuk bergabung ke kuis. Buat akun jika Anda juga perlu membuat kuis atau mengelola bank soal.',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            surface: CardSurface.low,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What you can do', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text('Join with a manual code or Bluetooth broadcast from a host.', style: textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Stay lightweight: no permanent account is created for guest sessions.', style: textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton.outlined(
            label: 'Scan / Change Session',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          const SizedBox(height: 12),
          AppButton.text(
            label: 'Log Out Guest',
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
