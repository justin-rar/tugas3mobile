// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../core/constants.dart';
import '../core/error_handler.dart';

class AuthService {
  final _client = Supabase.instance.client;

  /// Login dengan email + password
  Future<void> login(String email, String password) async {
    try {
      await _client.auth
          .signInWithPassword(email: email.trim(), password: password)
          .timeout(AppConstants.timeout);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Register dengan email + password
  Future<void> register(String email, String password) async {
    try {
      final res = await _client.auth
          .signUp(email: email.trim(), password: password)
          .timeout(AppConstants.timeout);

      // Jika email confirmation aktif, user.identities bisa kosong
      if (res.user?.identities?.isEmpty ?? false) {
        throw const AuthFailure('Email sudah terdaftar. Silakan login.');
      }
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _client.auth.signOut().timeout(AppConstants.timeout);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Email pengguna saat ini
  String? get currentEmail => _client.auth.currentUser?.email;

  /// Session saat ini
  Session? get currentSession => _client.auth.currentSession;
}
