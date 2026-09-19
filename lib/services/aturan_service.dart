// lib/services/aturan_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../core/error_handler.dart';

class AturanService {
  final _client = Supabase.instance.client;

  /// Ambil semua aturan hari baik (8 baris)
  Future<List<Map<String, dynamic>>> getAturan() async {
    try {
      final data = await _client
          .from('aturan_hari_baik')
          .select()
          .order('sisa')
          .timeout(AppConstants.timeout);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Ambil aturan berdasarkan sisa
  Future<Map<String, dynamic>?> getBySisa(int sisa) async {
    try {
      final data = await _client
          .from('aturan_hari_baik')
          .select()
          .eq('sisa', sisa)
          .maybeSingle()
          .timeout(AppConstants.timeout);
      return data;
    } catch (e) {
      throw mapError(e);
    }
  }
}
