// lib/services/acara_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../core/error_handler.dart';
import '../utils/kalender_util.dart';

class AcaraService {
  final _client = Supabase.instance.client;

  /// Ambil semua rencana acara milik user (urut terbaru)
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final data = await _client
          .from('rencana_acara')
          .select('*, orang(nama)')
          .order('created_at', ascending: false)
          .timeout(AppConstants.timeout);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Tambah rencana acara — hasil hari baik dihitung otomatis jika ada orang
  Future<void> create({
    String? orangId,
    required String jenisAcara,
    required DateTime tanggalAcara,
    String? catatan,
    DateTime? tanggalLahirOrang,
  }) async {
    try {
      String? hasil;
      if (tanggalLahirOrang != null) {
        final hb = KalenderUtil.cekHariAcara(tanggalLahirOrang, tanggalAcara);
        hasil = '${hb.nama} (${hb.baik ? "baik" : "kurang baik"})';
      }

      await _client.from('rencana_acara').insert({
        if (orangId != null) 'orang_id': orangId,
        'jenis_acara': jenisAcara,
        'tanggal_acara': _dateString(tanggalAcara),
        'hasil': hasil,
        'catatan': catatan?.trim(),
      }).timeout(AppConstants.timeout);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Update rencana acara
  Future<void> update({
    required String id,
    String? orangId,
    required String jenisAcara,
    required DateTime tanggalAcara,
    String? catatan,
    DateTime? tanggalLahirOrang,
  }) async {
    try {
      String? hasil;
      if (tanggalLahirOrang != null) {
        final hb = KalenderUtil.cekHariAcara(tanggalLahirOrang, tanggalAcara);
        hasil = '${hb.nama} (${hb.baik ? "baik" : "kurang baik"})';
      }

      await _client.from('rencana_acara').update({
        'orang_id': orangId,
        'jenis_acara': jenisAcara,
        'tanggal_acara': _dateString(tanggalAcara),
        'hasil': hasil,
        'catatan': catatan?.trim(),
      }).eq('id', id).timeout(AppConstants.timeout);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Hapus rencana acara
  Future<void> delete(String id) async {
    try {
      await _client
          .from('rencana_acara')
          .delete()
          .eq('id', id)
          .timeout(AppConstants.timeout);
    } catch (e) {
      throw mapError(e);
    }
  }

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
