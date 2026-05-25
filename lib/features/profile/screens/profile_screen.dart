import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/hive_service.dart';
import '../../../widgets/components/app_confirm_modal.dart';
import '../widgets/profile_menu_item.dart';
import 'tutorial_screen.dart';
import 'about_screen.dart';
import 'sound_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _editDisplayName() async {
    final session = AuthService.currentSession;
    if (session == null || session.isGuest) return;

    final controller = TextEditingController(text: session.displayName);
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Display Name'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: 'Display Name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name cannot be empty';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName != session.displayName && mounted) {
      try {
        await AuthService.updateDisplayName(newName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name successfully updated')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update name: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthService.currentSession;
    final initials = _buildInitials(session?.displayName ?? 'AR');

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Header Profile
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 32,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session?.displayName ?? 'Anonymous User',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (!(session?.isGuest ?? true)) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: _editDisplayName,
                  child: const Icon(Icons.edit, size: 20, color: Colors.blue),
                ),
              ],
            ],
          ),
          if (session?.isGuest ?? true)
            const Text(
              'Guest Account',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 24),

            // Statistik Singkat
            ProfileMenuItem(
              icon: Icons.delete_outline,
              title: 'Clear Offline Data',
              onTap: () async {
                final confirm = await AppConfirmModal.show(
                  context,
                  title: 'Clear Data',
                  content: 'Are you sure you want to clear all local quiz cache data?',
                  confirmText: 'Clear',
                  cancelText: 'Cancel',
                  isDestructive: true,
                );
                if (confirm == true) {
                  await HiveService.clearQuizCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offline data successfully cleared')),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ProfileMenuItem(
              icon: Icons.volume_up_outlined,
              title: 'Sound & Vibration',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SoundSettingsScreen()),
                );
              },
            ),
            const Divider(),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Tutorial & FAQ',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const Divider(),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: Colors.red,
              textColor: Colors.red,
              trailing: const SizedBox(), // Menghilangkan panah untuk tombol Keluar
              onTap: () async {
                final confirm = await AppConfirmModal.show(
                  context,
                  title: 'Logout',
                  content: 'Are you sure you want to log out of this account?',
                  confirmText: 'Logout',
                  cancelText: 'Cancel',
                  isDestructive: true,
                );
                
                if (confirm == true) {
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil('/app', (route) => false);
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
    );
  }

  String _buildInitials(String name) {
    name = name.trim();
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length == 1) {
      if (name.length == 1) return name.toUpperCase();
      return name.substring(0, 2).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
