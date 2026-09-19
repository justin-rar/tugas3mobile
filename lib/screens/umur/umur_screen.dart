// lib/screens/umur/umur_screen.dart
// Kalkulator umur live sampai detik (PRD F7)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/kalender_util.dart';

class UmurScreen extends StatefulWidget {
  const UmurScreen({super.key});

  @override
  State<UmurScreen> createState() => _UmurScreenState();
}

class _UmurScreenState extends State<UmurScreen> {
  DateTime? _tanggalLahir;
  TimeOfDay _jamLahir = const TimeOfDay(hour: 0, minute: 0);
  Timer? _timer;
  Umur? _umur;
  String? _errorMsg;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_tanggalLahir == null) return;

    final lahir = DateTime(
      _tanggalLahir!.year,
      _tanggalLahir!.month,
      _tanggalLahir!.day,
      _jamLahir.hour,
      _jamLahir.minute,
    );

    if (lahir.isAfter(DateTime.now())) {
      setState(() {
        _errorMsg = 'Tanggal lahir tidak boleh di masa depan.';
        _umur = null;
      });
      return;
    }

    setState(() => _errorMsg = null);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      try {
        setState(() {
          _umur = KalenderUtil.hitungUmur(lahir, DateTime.now());
        });
      } catch (e) {
        setState(() {
          _errorMsg = 'Perhitungan gagal. Coba tanggal lain.';
          _umur = null;
        });
        _timer?.cancel();
      }
    });

    // Hitung langsung tanpa tunggu 1 detik
    try {
      setState(() {
        _umur = KalenderUtil.hitungUmur(lahir, DateTime.now());
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Perhitungan gagal. Coba tanggal lain.';
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() => _tanggalLahir = picked);
      _startTimer();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _jamLahir,
    );
    if (picked != null) {
      setState(() => _jamLahir = picked);
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator Umur')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cake_outlined, size: 56, color: colorScheme.primary),
              const SizedBox(height: 24),

              // Pilih tanggal lahir
              Card(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.edit_calendar, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          _tanggalLahir != null
                              ? DateFormat('d MMMM yyyy', 'id_ID')
                                  .format(_tanggalLahir!)
                              : 'Pilih tanggal lahir',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Pilih jam lahir (opsional)
              Card(
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Jam lahir: ${_jamLahir.format(context)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '(opsional)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error
              if (_errorMsg != null)
                Card(
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMsg!,
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                  ),
                ),

              // Hasil umur
              if (_umur != null) ...[
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Umurmu',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _UmurChip('${_umur!.tahun}', 'Tahun', colorScheme),
                            _UmurChip('${_umur!.bulan}', 'Bulan', colorScheme),
                            _UmurChip('${_umur!.hari}', 'Hari', colorScheme),
                            _UmurChip('${_umur!.jam}', 'Jam', colorScheme),
                            _UmurChip('${_umur!.menit}', 'Menit', colorScheme),
                            _UmurChip('${_umur!.detik}', 'Detik', colorScheme),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_tanggalLahir != null)
                          Text(
                            'Total ${DateTime.now().difference(DateTime(_tanggalLahir!.year, _tanggalLahir!.month, _tanggalLahir!.day)).inDays} hari hidup',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UmurChip extends StatelessWidget {
  final String value;
  final String label;
  final ColorScheme colorScheme;

  const _UmurChip(this.value, this.label, this.colorScheme);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
        ),
      ],
    );
  }
}
