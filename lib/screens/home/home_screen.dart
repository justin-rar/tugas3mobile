// lib/screens/home/home_screen.dart
// Beranda: 6 menu vertikal di tengah layar (PRD F2)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../anggota/anggota_screen.dart';
import '../hari_baik/hari_baik_screen.dart';
import '../crud/crud_screen.dart';
import '../hijriah/hijriah_screen.dart';
import '../umur/umur_screen.dart';
import '../kalender/kalender_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sapaan
                Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hari Baik',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Halo, $email',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),

                // 6 menu
                _MenuCard(
                  icon: Icons.groups_outlined,
                  title: 'Daftar Anggota',
                  subtitle: 'Lihat anggota kelompok',
                  color: colorScheme.primaryContainer,
                  iconColor: colorScheme.onPrimaryContainer,
                  onTap: () => _push(context, const AnggotaScreen()),
                ),
                _MenuCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Hitung Hari Baik',
                  subtitle: 'Kecocokan & cek tanggal acara',
                  color: colorScheme.secondaryContainer,
                  iconColor: colorScheme.onSecondaryContainer,
                  onTap: () => _push(context, const HariBaikScreen()),
                ),
                _MenuCard(
                  icon: Icons.people_alt_outlined,
                  title: 'Data Orang & Acara',
                  subtitle: 'Kelola data orang dan rencana acara',
                  color: colorScheme.tertiaryContainer,
                  iconColor: colorScheme.onTertiaryContainer,
                  onTap: () => _push(context, const CrudScreen()),
                ),
                _MenuCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Konversi Hijriah',
                  subtitle: 'Masehi ke Hijriah',
                  color: colorScheme.primaryContainer,
                  iconColor: colorScheme.onPrimaryContainer,
                  onTap: () => _push(context, const HijriahScreen()),
                ),
                _MenuCard(
                  icon: Icons.cake_outlined,
                  title: 'Kalkulator Umur',
                  subtitle: 'Hitung umur hingga detik',
                  color: colorScheme.secondaryContainer,
                  iconColor: colorScheme.onSecondaryContainer,
                  onTap: () => _push(context, const UmurScreen()),
                ),
                _MenuCard(
                  icon: Icons.event_note_outlined,
                  title: 'Kalender Weton & Saka Bali',
                  subtitle: 'Weton, wuku, dan Saka Bali',
                  color: colorScheme.tertiaryContainer,
                  iconColor: colorScheme.onTertiaryContainer,
                  onTap: () => _push(context, const KalenderScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: color,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, size: 32, color: iconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
