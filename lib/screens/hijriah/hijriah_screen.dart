// lib/screens/hijriah/hijriah_screen.dart
// Konversi tanggal Masehi ke Hijriah (PRD F6)

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class HijriahScreen extends StatefulWidget {
  const HijriahScreen({super.key});

  @override
  State<HijriahScreen> createState() => _HijriahScreenState();
}

class _HijriahScreenState extends State<HijriahScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _hijriResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _convert();
  }

  void _convert() {
    try {
      final h = HijriCalendar.fromDate(_selectedDate);
      setState(() {
        _hijriResult = '${h.hDay} ${h.longMonthName} ${h.hYear} H';
        _error = null;
      });
    } catch (e) {
      setState(() {
        _hijriResult = null;
        _error = 'Tanggal di luar rentang konversi Hijriah.';
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
      _convert();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Hijriah')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Tanggal Masehi
              Card(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_calendar, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          formatted,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hasil Hijriah
              if (_hijriResult != null)
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Tanggal Hijriah',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hijriResult!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_error != null)
                Card(
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.onErrorContainer),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              // Catatan disclaimer
              Text(
                'Catatan: Hasil konversi bisa berbeda 1 hari dari penetapan Kemenag RI.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
