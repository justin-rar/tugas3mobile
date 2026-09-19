// lib/screens/crud/orang_list_screen.dart
// List data orang + CRUD (PRD F5)

import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../services/orang_service.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import 'orang_form_screen.dart';

class OrangListScreen extends StatefulWidget {
  const OrangListScreen({super.key});

  @override
  State<OrangListScreen> createState() => OrangListScreenState();
}

class OrangListScreenState extends State<OrangListScreen> {
  final _service = OrangService();
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
        title: const Text('Hapus Data'),
        content: const Text('Yakin ingin menghapus data orang ini?'),
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
          content: const Text('Data berhasil dihapus.'),
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
        heroTag: 'fab_orang',
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const OrangFormScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_data == null || _data!.isEmpty) {
      return const EmptyView(
        message: 'Belum ada data orang.\nTambahkan data pertamamu!',
        icon: Icons.person_add_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _data!.length,
        itemBuilder: (context, index) {
          final item = _data![index];
          final nama = item['nama'] ?? '-';
          final hari = item['hari'] ?? '';
          final pasaran = item['pasaran'] ?? '';
          final neptu = item['neptu']?.toString() ?? '-';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.tertiaryContainer,
                child: Text(
                  nama[0].toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(nama,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('$hari $pasaran · Neptu: $neptu'),
              trailing: PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrangFormScreen(data: item),
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
