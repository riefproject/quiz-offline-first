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
          title: const Text('Ganti Nama Tampilan'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: 'Nama Tampilan',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
              child: const Text('Simpan'),
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
            const SnackBar(content: Text('Nama berhasil diperbarui')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui nama: $e')),
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
                session?.displayName ?? 'Pengguna Anonim',
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
              'Akun Tamu',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 24),

            // Statistik Singkat
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Riwayat Kuis',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menampilkan riwayat kuis...')),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.delete_outline,
              title: 'Hapus Data Offline',
              onTap: () async {
                final confirm = await AppConfirmModal.show(
                  context,
                  title: 'Hapus Data',
                  content: 'Apakah Anda yakin ingin menghapus seluruh local cache data kuis?',
                  confirmText: 'Hapus',
                  cancelText: 'Batal',
                  isDestructive: true,
                );
                if (confirm == true) {
                  await HiveService.clearQuizCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data offline berhasil dihapus')),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ProfileMenuItem(
              icon: Icons.volume_up_outlined,
              title: 'Suara & Getaran',
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
              title: 'Tentang Aplikasi',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const Divider(),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Keluar',
              iconColor: Colors.red,
              textColor: Colors.red,
              trailing: const SizedBox(), // Menghilangkan panah untuk tombol Keluar
              onTap: () async {
                final confirm = await AppConfirmModal.show(
                  context,
                  title: 'Keluar Akun',
                  content: 'Apakah Anda yakin ingin keluar dari akun ini?',
                  confirmText: 'Keluar',
                  cancelText: 'Batal',
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

