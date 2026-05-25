import 'package:flutter/material.dart';

class SyncStatusCard extends StatelessWidget {
  final DateTime? lastSync;
  final VoidCallback onSyncPressed;

  const SyncStatusCard({
    super.key,
    this.lastSync,
    required this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_sync, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sync Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        lastSync != null 
                            ? 'Last sync: ${lastSync!.hour}:${lastSync!.minute.toString().padLeft(2, '0')}'
                            : 'Never synced',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onSyncPressed,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Sync'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
