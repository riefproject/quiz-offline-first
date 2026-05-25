import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/colors_config.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';

class GuestJoinPage extends StatefulWidget {
  const GuestJoinPage({super.key});

  @override
  State<GuestJoinPage> createState() => _GuestJoinPageState();
}

class _GuestJoinPageState extends State<GuestJoinPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.continueAsGuest(
        namaLengkap: _nameController.text,
        joinCode: _codeController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/app');
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Guest join gagal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        decoration: BoxDecoration(
          color: colors.surfaceLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter your name to join',
                style: textTheme.titleLarge?.copyWith(
                  color: colors.textOnSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a nickname to start competing in live leagues.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textOnSurface,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Your display name',
                hintText: 'e.g. QuizMaster99',
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Session code (optional)',
                hintText: 'Enter session code',
                controller: _codeController,
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                label: _isSubmitting ? 'Joining...' : 'Join Now',
                onPressed: _isSubmitting ? null : _continueAsGuest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
