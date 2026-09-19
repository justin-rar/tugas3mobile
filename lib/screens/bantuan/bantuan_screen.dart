// lib/screens/bantuan/bantuan_screen.dart
// Panduan penggunaan + tombol Logout (PRD F10)

import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Daftar Anggota',
            'Menampilkan daftar anggota kelompok (nama, NIM, peran). '
                'Tarik ke bawah untuk memperbarui data.',
          ),
          _buildSection(
            'Hitung Hari Baik',
            'Cek kecocokan dua orang berdasarkan weton, atau cek tanggal acara '
                'untuk seseorang. Menggunakan metode neptu (jumlah nilai hari + pasaran) '
                'mod 8. Hasil: Pegat, Ratu, Jodoh, Topo, Tinari, Padu, Sujanan, atau Pesthi.',
          ),
          _buildSection(
            'Data Orang & Acara',
            'Tambah, edit, dan hapus data orang (nama + tanggal lahir). '
                'Weton dan neptu dihitung otomatis. '
                'Kelola rencana acara beserta hasil hari baiknya.',
          ),
          _buildSection(
            'Konversi Hijriah',
            'Pilih tanggal Masehi untuk melihat tanggal Hijriah. '
                'Hasil bisa berbeda 1 hari dari penetapan Kemenag RI.',
          ),
          _buildSection(
            'Kalkulator Umur',
            'Masukkan tanggal dan jam lahir untuk melihat umur '
                'dalam tahun, bulan, hari, jam, menit, dan detik (real-time).',
          ),
          _buildSection(
            'Kalender Weton & Saka Bali',
            'Pilih tanggal untuk melihat hari pasaran (weton), neptu, dan wuku. '
                'Juga menampilkan konversi Saka Bali (tahun Saka, saptawara, pancawara, wuku). '
                'Catatan: ini versi sederhana, bukan kalender lunar Bali lengkap.',
          ),
          _buildSection(
            'Stopwatch',
            'Stopwatch dengan fitur start/pause, reset, dan lap. '
                'State dipertahankan saat pindah tab.',
          ),
          _buildSection(
            'Metode Hitung',
            'Neptu dihitung dari jumlah nilai hari (Minggu=5, Senin=4, Selasa=3, '
                'Rabu=7, Kamis=8, Jumat=6, Sabtu=9) dan nilai pasaran (Legi=5, '
                'Pahing=9, Pon=7, Wage=4, Kliwon=8). Total neptu mod 8 '
                'menentukan hasil (sisa 0 dianggap 8). Hasil berdasarkan primbon '
                'tradisional, bukan kepastian.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Tombol Logout
          Center(
            child: FilledButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                minimumSize: const Size(200, 48),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(content, style: const TextStyle(height: 1.5)),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await AuthService().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              } on AppException catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
