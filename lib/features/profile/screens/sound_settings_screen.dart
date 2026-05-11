import 'package:flutter/material.dart';

class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suara & Getaran'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Pengaturan Audio',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Efek Suara (SFX)'),
            subtitle: const Text('Putar suara saat menjawab benar atau salah'),
            value: _isSoundEnabled,
            activeColor: Colors.blue,
            onChanged: (bool value) {
              setState(() {
                _isSoundEnabled = value;
              });
            },
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Pengaturan Haptic',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Getaran'),
            subtitle: const Text('Getar saat waktu hampir habis'),
            value: _isVibrationEnabled,
            activeColor: Colors.blue,
            onChanged: (bool value) {
              setState(() {
                _isVibrationEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
