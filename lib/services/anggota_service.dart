// lib/services/anggota_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../core/error_handler.dart';

class AnggotaService {
  final _client = Supabase.instance.client;

  /// Ambil semua data anggota
  Future<List<Map<String, dynamic>>> getAnggota() async {
    try {
      final data = await _client
          .from('anggota')
          .select()
          .order('id')
          .timeout(AppConstants.timeout);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw mapError(e);
    }
  }
}
