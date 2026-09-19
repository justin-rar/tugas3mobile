// lib/screens/crud/acara_form_screen.dart
// Form tambah/edit rencana acara (PRD F5)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_exception.dart';
import '../../core/constants.dart';
import '../../services/acara_service.dart';
import '../../services/orang_service.dart';
import '../../utils/validators.dart';

class AcaraFormScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const AcaraFormScreen({super.key, this.data});

  @override
  State<AcaraFormScreen> createState() => _AcaraFormScreenState();
}

class _AcaraFormScreenState extends State<AcaraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanCtrl = TextEditingController();
  final _acaraService = AcaraService();
  final _orangService = OrangService();

  String? _jenisAcara;
  DateTime? _tanggalAcara;
  String? _selectedOrangId;
  DateTime? _selectedOrangTglLahir;
  List<Map<String, dynamic>> _orangList = [];
  bool _loading = false;
  bool _loadingOrang = true;

  bool get _isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    _loadOrangList();

    if (_isEdit) {
      _jenisAcara = widget.data!['jenis_acara'];
      _catatanCtrl.text = widget.data!['catatan'] ?? '';
      final tglStr = widget.data!['tanggal_acara'];
      if (tglStr != null) _tanggalAcara = DateTime.tryParse(tglStr);
      _selectedOrangId = widget.data!['orang_id'];
    }
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOrangList() async {
    try {
      final data = await _orangService.getAll();
      if (!mounted) return;
      setState(() {
        _orangList = data;
        _loadingOrang = false;
        // Set tanggal lahir jika ada orang terpilih
        if (_selectedOrangId != null) {
          final orang = _orangList
              .where((o) => o['id'] == _selectedOrangId)
              .firstOrNull;
          if (orang != null && orang['tanggal_lahir'] != null) {
            _selectedOrangTglLahir =
                DateTime.tryParse(orang['tanggal_lahir']);
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingOrang = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalAcara ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => _tanggalAcara = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tglError = Validators.tanggalAcara(_tanggalAcara);
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
        await _acaraService.update(
          id: widget.data!['id'],
          orangId: _selectedOrangId,
          jenisAcara: _jenisAcara!,
          tanggalAcara: _tanggalAcara!,
          catatan: _catatanCtrl.text,
          tanggalLahirOrang: _selectedOrangTglLahir,
        );
      } else {
        await _acaraService.create(
          orangId: _selectedOrangId,
          jenisAcara: _jenisAcara!,
          tanggalAcara: _tanggalAcara!,
          catatan: _catatanCtrl.text,
          tanggalLahirOrang: _selectedOrangTglLahir,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Acara berhasil diperbarui.' : 'Acara berhasil ditambahkan.',
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
        title: Text(_isEdit ? 'Edit Acara' : 'Tambah Acara'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pilih orang (opsional)
              _loadingOrang
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String?>(
                      initialValue: _selectedOrangId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Orang (opsional)',
                        prefixIcon: Icon(Icons.person_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Tanpa orang'),
                        ),
                        ..._orangList.map((o) => DropdownMenuItem(
                              value: o['id'] as String,
                              child: Text(o['nama'] ?? '-'),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedOrangId = val;
                          if (val != null) {
                            final orang = _orangList
                                .where((o) => o['id'] == val)
                                .firstOrNull;
                            _selectedOrangTglLahir = orang != null
                                ? DateTime.tryParse(
                                    orang['tanggal_lahir'] ?? '')
                                : null;
                          } else {
                            _selectedOrangTglLahir = null;
                          }
                        });
                      },
                    ),
              const SizedBox(height: 16),

              // Jenis acara
              DropdownButtonFormField<String>(
                initialValue: _jenisAcara,
                decoration: const InputDecoration(
                  labelText: 'Jenis Acara *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.jenisAcara
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (val) => setState(() => _jenisAcara = val),
                validator: Validators.jenisAcara,
              ),
              const SizedBox(height: 16),

              // Tanggal acara
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
                          _tanggalAcara != null
                              ? DateFormat('d MMMM yyyy', 'id_ID')
                                  .format(_tanggalAcara!)
                              : 'Pilih tanggal acara *',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan
              TextFormField(
                controller: _catatanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  prefixIcon: Icon(Icons.note_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
