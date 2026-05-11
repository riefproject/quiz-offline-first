import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial & FAQ'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem(
            'Bagaimana cara memulai kuis offline?',
            'Untuk memulai kuis offline, pastikan Anda telah sinkronisasi data kuis setidaknya sekali sebelumnya menggunakan tombol Sync pada profil, atau telah mengunduh soal kuis. Setelah itu Anda bisa bermain secara offline tanpa kendala.',
          ),
          _buildFaqItem(
            'Apakah data akan hilang saat mengganti device?',
            'Selama Anda sudah mendaftar dan berhasil sinkronisasi atau menggunakan koneksi internet untuk meng-upload progress kuis ke Cloud, data akan tersimpan aman.',
          ),
          _buildFaqItem(
            'Mengapa tombol Sync penting?',
            'Tombol Sync memungkinkan aplikasi untuk memadukan (merilis ke server) progress offline yang sudah dikerjakan, dan sebaliknya (mengunduh kuis yang baru jadi) dari backend Database Cloud.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
