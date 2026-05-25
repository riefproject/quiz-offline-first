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
        title: const Text('Sound & Vibration'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Audio Settings',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Sound Effects (SFX)'),
            subtitle: const Text('Play sound when answering correctly or incorrectly'),
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
            'Haptic Settings',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate when time is running out'),
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
