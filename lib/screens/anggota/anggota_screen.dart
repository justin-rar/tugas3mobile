// lib/screens/anggota/anggota_screen.dart
// Daftar anggota kelompok dengan pull-to-refresh (PRD F3)

import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../services/anggota_service.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  final _service = AnggotaService();
  List<Map<String, dynamic>>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getAnggota();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota')),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_data == null || _data!.isEmpty) {
      return const EmptyView(message: 'Belum ada data anggota.');
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _data!.length,
        itemBuilder: (context, index) {
          final item = _data![index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  (item['nama'] as String? ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                item['nama'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('NIM: ${item['nim'] ?? '-'}'),
              trailing: Chip(
                label: Text(
                  item['peran'] ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: colorScheme.secondaryContainer,
                side: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }
}
