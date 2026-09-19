// lib/screens/crud/orang_form_screen.dart
// Form tambah/edit orang (PRD F5)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_exception.dart';
import '../../services/orang_service.dart';
import '../../utils/validators.dart';
import '../../utils/kalender_util.dart';

class OrangFormScreen extends StatefulWidget {
  final Map<String, dynamic>? data; // null = create, non-null = edit

  const OrangFormScreen({super.key, this.data});

  @override
  State<OrangFormScreen> createState() => _OrangFormScreenState();
}

class _OrangFormScreenState extends State<OrangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _service = OrangService();
  DateTime? _tanggalLahir;
  Weton? _previewWeton;
  bool _loading = false;

  bool get _isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _namaCtrl.text = widget.data!['nama'] ?? '';
      final tglStr = widget.data!['tanggal_lahir'];
      if (tglStr != null) {
        _tanggalLahir = DateTime.tryParse(tglStr);
        if (_tanggalLahir != null) {
          _previewWeton = KalenderUtil.hitungWeton(_tanggalLahir!);
        }
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
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
      setState(() {
        _tanggalLahir = picked;
        try {
          _previewWeton = KalenderUtil.hitungWeton(picked);
        } catch (_) {
          _previewWeton = null;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tglError = Validators.tanggalLahir(_tanggalLahir);
    if (tglError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tglError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isEdit) {
        await _service.update(
          widget.data!['id'],
          _namaCtrl.text,
          _tanggalLahir!,
        );
      } else {
        await _service.create(_namaCtrl.text, _tanggalLahir!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Data berhasil diperbarui.' : 'Data berhasil ditambahkan.',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context, true);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Orang' : 'Tambah Orang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.nama,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Tanggal lahir
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
                              : 'Pilih tanggal lahir *',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preview weton
              if (_previewWeton != null)
                Card(
                  color: colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview Weton',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_previewWeton!.teks} · Neptu: ${_previewWeton!.neptu}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                        ),
                        Text(
                          'Wuku: ${_previewWeton!.wuku}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Tombol simpan
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? 'Perbarui' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
