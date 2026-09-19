// lib/services/orang_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../core/error_handler.dart';
import '../utils/kalender_util.dart';

class OrangService {
  final _client = Supabase.instance.client;

  /// Ambil semua data orang milik user (urut terbaru)
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final data = await _client
          .from('orang')
          .select()
          .order('created_at', ascending: false)
          .timeout(AppConstants.timeout);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Tambah orang baru — hari, pasaran, neptu dihitung otomatis
  Future<void> create(String nama, DateTime tanggalLahir) async {
    try {
      final weton = KalenderUtil.hitungWeton(tanggalLahir);
      await _client.from('orang').insert({
        'nama': nama.trim(),
        'tanggal_lahir': _dateString(tanggalLahir),
        'hari': weton.hari,
        'pasaran': weton.pasaran,
        'neptu': weton.neptu,
      }).timeout(AppConstants.timeout);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Update data orang — hitung ulang weton jika tanggal berubah
  Future<void> update(String id, String nama, DateTime tanggalLahir) async {
    try {
      final weton = KalenderUtil.hitungWeton(tanggalLahir);
      await _client.from('orang').update({
        'nama': nama.trim(),
        'tanggal_lahir': _dateString(tanggalLahir),
        'hari': weton.hari,
        'pasaran': weton.pasaran,
        'neptu': weton.neptu,
      }).eq('id', id).timeout(AppConstants.timeout);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Hapus orang berdasarkan ID
  Future<void> delete(String id) async {
    try {
      await _client
          .from('orang')
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
