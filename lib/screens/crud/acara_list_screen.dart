// lib/screens/crud/acara_list_screen.dart
// List rencana acara + CRUD (PRD F5)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_exception.dart';
import '../../services/acara_service.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import 'acara_form_screen.dart';

class AcaraListScreen extends StatefulWidget {
  const AcaraListScreen({super.key});

  @override
  State<AcaraListScreen> createState() => _AcaraListScreenState();
}

class _AcaraListScreenState extends State<AcaraListScreen> {
  final _service = AcaraService();
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
      final data = await _service.getAll();
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

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Acara'),
        content: const Text('Yakin ingin menghapus rencana acara ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.delete(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Acara berhasil dihapus.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      _load();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _buildBody(colorScheme),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_acara',
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AcaraFormScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_data == null || _data!.isEmpty) {
      return const EmptyView(
        message: 'Belum ada rencana acara.\nTambahkan acara pertamamu!',
        icon: Icons.event_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _data!.length,
        itemBuilder: (context, index) {
          final item = _data![index];
          final jenis = item['jenis_acara'] ?? '-';
          final tglStr = item['tanggal_acara'];
          final tanggal = tglStr != null
              ? DateFormat('d MMM yyyy', 'id_ID')
                  .format(DateTime.parse(tglStr))
              : '-';
          final hasil = item['hasil'] ?? '-';
          final orangData = item['orang'];
          final namaOrang = orangData is Map
              ? (orangData['nama'] ?? 'Orang dihapus')
              : 'Tanpa orang';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  Icons.event,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              title: Text(jenis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('$tanggal · $namaOrang\nHasil: $hasil'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AcaraFormScreen(data: item),
                      ),
                    );
                    if (result == true) _load();
                  } else if (action == 'delete') {
                    _delete(item['id']);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
