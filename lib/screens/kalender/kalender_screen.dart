// lib/screens/kalender/kalender_screen.dart
// Kalender Weton & Saka Bali (PRD F8)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/kalender_util.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  DateTime _selectedDate = DateTime.now();
  Weton? _weton;
  SakaBali? _saka;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    try {
      setState(() {
        _weton = KalenderUtil.hitungWeton(_selectedDate);
        _saka = KalenderUtil.hitungSakaBali(_selectedDate);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Perhitungan gagal. Coba tanggal lain.';
        _weton = null;
        _saka = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatted =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Weton & Saka Bali')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pilih tanggal
            Card(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.edit_calendar, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(formatted,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Card(
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ),

            // Weton
            if (_weton != null) ...[
              Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weton',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow('Hari Pasaran', _weton!.teks),
                      _InfoRow('Neptu Hari', '${_weton!.neptuHari}'),
                      _InfoRow('Neptu Pasaran', '${_weton!.neptuPasaran}'),
                      _InfoRow('Total Neptu', '${_weton!.neptu}'),
                      _InfoRow('Wuku', _weton!.wuku),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Saka Bali
            if (_saka != null) ...[
              Card(
                color: colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saka Bali',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow('Tahun Saka', '${_saka!.tahunSaka}'),
                      _InfoRow('Saptawara', _saka!.saptawara),
                      _InfoRow('Pancawara', _saka!.pancawara),
                      _InfoRow('Wuku', _saka!.wuku),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Catatan: Saka Bali di sini adalah versi sederhana '
                '(tahun Saka + wewaran + wuku), bukan kalender lunar Bali lengkap.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
