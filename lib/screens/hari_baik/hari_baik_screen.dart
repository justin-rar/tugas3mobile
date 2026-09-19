// lib/screens/hari_baik/hari_baik_screen.dart
// Hitung Hari Baik: kecocokan dua orang & cek tanggal acara (PRD F4)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_exception.dart';
import '../../services/orang_service.dart';
import '../../services/aturan_service.dart';
import '../../services/acara_service.dart';
import '../../utils/kalender_util.dart';

class HariBaikScreen extends StatefulWidget {
  const HariBaikScreen({super.key});

  @override
  State<HariBaikScreen> createState() => _HariBaikScreenState();
}

class _HariBaikScreenState extends State<HariBaikScreen> {
  // Mode: 0 = kecocokan, 1 = cek acara
  int _mode = 0;

  // Data orang dari database
  List<Map<String, dynamic>> _orangList = [];
  bool _loadingOrang = true;

  // Kecocokan
  DateTime? _tglA;
  DateTime? _tglB;
  String? _namaA;
  String? _namaB;

  // Cek acara
  DateTime? _tglOrang;
  DateTime? _tglAcara;
  String? _namaOrang;
  String? _orangIdAcara;

  // Hasil
  _HasilDetail? _hasil;
  bool _saving = false;

  final _orangService = OrangService();
  final _aturanService = AturanService();
  final _acaraService = AcaraService();

  @override
  void initState() {
    super.initState();
    _loadOrang();
  }

  Future<void> _loadOrang() async {
    try {
      final data = await _orangService.getAll();
      if (!mounted) return;
      setState(() {
        _orangList = data;
        _loadingOrang = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingOrang = false);
    }
  }

  Future<void> _pickDate(int target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked == null) return;

    setState(() {
      switch (target) {
        case 0:
          _tglA = picked;
          _namaA = null;
        case 1:
          _tglB = picked;
          _namaB = null;
        case 2:
          _tglOrang = picked;
          _namaOrang = null;
          _orangIdAcara = null;
        case 3:
          _tglAcara = picked;
      }
      _hasil = null;
    });
  }

  void _selectOrang(int target) {
    if (_orangList.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pilih dari data orang',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          ..._orangList.map((o) {
            final nama = o['nama'] ?? '-';
            final tgl = o['tanggal_lahir'];
            return ListTile(
              title: Text(nama),
              subtitle: Text('${o['hari']} ${o['pasaran']}'),
              onTap: () {
                Navigator.pop(ctx);
                if (tgl == null) return;
                final dt = DateTime.tryParse(tgl);
                if (dt == null) return;
                setState(() {
                  switch (target) {
                    case 0:
                      _tglA = dt;
                      _namaA = nama;
                    case 1:
                      _tglB = dt;
                      _namaB = nama;
                    case 2:
                      _tglOrang = dt;
                      _namaOrang = nama;
                      _orangIdAcara = o['id'];
                  }
                  _hasil = null;
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> _hitung() async {
    HasilHariBaik hb;
    Weton wetonA;
    Weton? wetonB;

    if (_mode == 0) {
      if (_tglA == null || _tglB == null) {
        _snack('Pilih dua tanggal lahir terlebih dahulu.');
        return;
      }
      wetonA = KalenderUtil.hitungWeton(_tglA!);
      wetonB = KalenderUtil.hitungWeton(_tglB!);
      hb = KalenderUtil.kecocokan(_tglA!, _tglB!);
    } else {
      if (_tglOrang == null || _tglAcara == null) {
        _snack('Pilih tanggal lahir orang dan tanggal acara.');
        return;
      }
      wetonA = KalenderUtil.hitungWeton(_tglOrang!);
      wetonB = KalenderUtil.hitungWeton(_tglAcara!);
      hb = KalenderUtil.cekHariAcara(_tglOrang!, _tglAcara!);
    }

    // Coba ambil arti dari database
    String arti = '';
    try {
      final aturan = await _aturanService.getBySisa(hb.sisa);
      if (aturan != null) arti = aturan['arti'] ?? '';
    } catch (_) {
      // Fallback lokal
      arti = _fallbackArti(hb.sisa);
    }

    setState(() {
      _hasil = _HasilDetail(
        wetonA: wetonA,
        wetonB: wetonB,
        totalNeptu: wetonA.neptu + (wetonB?.neptu ?? 0),
        sisa: hb.sisa,
        nama: hb.nama,
        baik: hb.baik,
        arti: arti,
      );
    });
  }

  String _fallbackArti(int sisa) {
    const map = {
      1: 'Rawan perpisahan atau perselisihan',
      2: 'Dihormati, berwibawa',
      3: 'Cocok, harmonis',
      4: 'Banyak ujian di awal, perlu kesabaran',
      5: 'Mudah rezeki dan bahagia',
      6: 'Ada perbedaan tapi bisa diselesaikan',
      7: 'Rawan godaan atau masalah',
      8: 'Tenteram dan sejahtera',
    };
    return map[sisa] ?? '';
  }

  Future<void> _simpanAcara() async {
    if (_tglAcara == null || _hasil == null) return;
    setState(() => _saving = true);

    try {
      await _acaraService.create(
        orangId: _orangIdAcara,
        jenisAcara: 'Lainnya',
        tanggalAcara: _tglAcara!,
        catatan:
            'Hasil: ${_hasil!.nama} (${_hasil!.baik ? "baik" : "kurang baik"})',
        tanggalLahirOrang: _tglOrang,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Disimpan sebagai rencana acara.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hitung Hari Baik')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle mode
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Kecocokan'),
                  icon: Icon(Icons.favorite_outline),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Cek Acara'),
                  icon: Icon(Icons.event_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                _hasil = null;
              }),
            ),
            const SizedBox(height: 20),

            if (_loadingOrang) const LinearProgressIndicator(),

            // Input sesuai mode
            if (_mode == 0) ..._buildKecocokan(colorScheme),
            if (_mode == 1) ..._buildCekAcara(colorScheme),

            const SizedBox(height: 16),

            // Tombol hitung
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _hitung,
                icon: const Icon(Icons.calculate),
                label: const Text('Hitung'),
              ),
            ),

            // Hasil
            if (_hasil != null) ...[
              const SizedBox(height: 24),
              _buildHasil(colorScheme),
            ],

            const SizedBox(height: 24),
            Text(
              'Hasil berdasarkan primbon tradisional, bukan kepastian.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKecocokan(ColorScheme cs) {
    return [
      _DatePickerTile(
        label: _namaA ?? 'Orang Pertama',
        date: _tglA,
        onPick: () => _pickDate(0),
        onSelect: _orangList.isNotEmpty ? () => _selectOrang(0) : null,
      ),
      const SizedBox(height: 12),
      _DatePickerTile(
        label: _namaB ?? 'Orang Kedua',
        date: _tglB,
        onPick: () => _pickDate(1),
        onSelect: _orangList.isNotEmpty ? () => _selectOrang(1) : null,
      ),
    ];
  }

  List<Widget> _buildCekAcara(ColorScheme cs) {
    return [
      _DatePickerTile(
        label: _namaOrang ?? 'Tanggal Lahir Orang',
        date: _tglOrang,
        onPick: () => _pickDate(2),
        onSelect: _orangList.isNotEmpty ? () => _selectOrang(2) : null,
      ),
      const SizedBox(height: 12),
      _DatePickerTile(
        label: 'Tanggal Acara',
        date: _tglAcara,
        onPick: () => _pickDate(3),
      ),
    ];
  }

  Widget _buildHasil(ColorScheme cs) {
    final h = _hasil!;
    final badgeColor = h.baik ? Colors.green : Colors.orange;

    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                h.baik ? '✓ Baik' : '✗ Kurang Baik',
                style: TextStyle(
                  color: badgeColor.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nama hasil
            Text(
              h.nama,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              h.arti,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 32),

            // Detail
            _DetailRow('Weton A', '${h.wetonA.teks} (${h.wetonA.neptu})'),
            if (h.wetonB != null)
              _DetailRow('Weton B', '${h.wetonB!.teks} (${h.wetonB!.neptu})'),
            _DetailRow('Total Neptu', '${h.totalNeptu}'),
            _DetailRow('Sisa (mod 8)', '${h.sisa}'),

            // Simpan sebagai acara (mode cek acara)
            if (_mode == 1 && _tglAcara != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _saving ? null : _simpanAcara,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Simpan sebagai rencana acara'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback? onSelect;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onPick,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onPick,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      date != null
                          ? DateFormat('d MMMM yyyy', 'id_ID').format(date!)
                          : 'Pilih tanggal',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onPick,
              icon: const Icon(Icons.edit_calendar),
            ),
            if (onSelect != null)
              IconButton(
                onPressed: onSelect,
                icon: const Icon(Icons.person_search),
                tooltip: 'Pilih dari data orang',
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HasilDetail {
  final Weton wetonA;
  final Weton? wetonB;
  final int totalNeptu;
  final int sisa;
  final String nama;
  final bool baik;
  final String arti;

  _HasilDetail({
    required this.wetonA,
    this.wetonB,
    required this.totalNeptu,
    required this.sisa,
    required this.nama,
    required this.baik,
    required this.arti,
  });
}
