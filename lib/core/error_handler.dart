// lib/core/error_handler.dart
// Memetakan exception mentah ke AppException dengan pesan Bahasa Indonesia.
// Dipakai oleh semua service class.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

AppException mapError(Object e) {
  debugPrint('[ErrorHandler] $e');

  // --- Jaringan ---
  if (e is SocketException || e is HandshakeException) {
    return const NetworkException(
      'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
    );
  }
  if (e is TimeoutException) {
    return const NetworkException(
      'Server terlalu lama merespons. Coba lagi.',
    );
  }
  if (e is HttpException) {
    return const NetworkException(
      'Gagal terhubung ke server. Coba lagi.',
    );
  }

  // --- Auth (Supabase) ---
  if (e is AuthException) {
    return _mapAuthError(e);
  }

  // --- Database (Supabase Postgrest) ---
  if (e is PostgrestException) {
    return _mapPostgrestError(e);
  }

  // --- Format / parsing ---
  if (e is FormatException || e is TypeError) {
    return const UnknownFailure('Data dari server tidak sesuai format.');
  }

  // --- AppException yang sudah di-map (re-throw) ---
  if (e is AppException) return e;

  return const UnknownFailure('Terjadi kesalahan tak terduga. Coba lagi.');
}

// Pemetaan error auth sesuai tabel PRD 8.3
AuthFailure _mapAuthError(AuthException e) {
  final msg = (e.message).toLowerCase();
  final code = e.code?.toLowerCase() ?? '';

  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid_credentials') ||
      code == 'invalid_credentials') {
    return const AuthFailure('Email atau password salah.');
  }
  if (msg.contains('email not confirmed') || code == 'email_not_confirmed') {
    return const AuthFailure(
      'Email belum dikonfirmasi. Cek kotak masuk emailmu.',
    );
  }
  if (msg.contains('user already registered') ||
      msg.contains('already registered') ||
      code == 'user_already_exists') {
    return const AuthFailure('Email sudah terdaftar. Silakan login.');
  }
  if (msg.contains('weak_password') ||
      msg.contains('password') && msg.contains('short') ||
      code == 'weak_password') {
    return const AuthFailure(
      'Password terlalu lemah. Gunakan minimal 6 karakter.',
    );
  }
  if (msg.contains('valid email') ||
      msg.contains('invalid email') ||
      code == 'validation_failed') {
    return const AuthFailure('Format email tidak valid.');
  }
  if (msg.contains('rate limit') ||
      msg.contains('too many requests') ||
      code == 'over_request_rate_limit') {
    return const AuthFailure(
      'Terlalu banyak percobaan. Tunggu beberapa saat lalu coba lagi.',
    );
  }

  return const AuthFailure('Gagal masuk. Coba lagi.');
}

// Pemetaan error Postgrest sesuai PRD 8.5
DatabaseFailure _mapPostgrestError(PostgrestException e) {
  final code = e.code ?? '';
  final msg = (e.message).toLowerCase();

  // RLS / permission denied
  if (code == '42501') {
    return const DatabaseFailure('Kamu tidak punya izin untuk aksi ini.');
  }
  // Table / column not found
  if (code == '42P01' || code == '42703') {
    return const DatabaseFailure('Data belum siap. Hubungi pengembang.');
  }
  // Not found (empty result when expecting single)
  if (msg.contains('not found') || msg.contains('0 rows')) {
    return const DatabaseFailure(
      'Data tidak ditemukan. Mungkin sudah dihapus.',
    );
  }
  // Constraint violation
  if (code == '23505' || code == '23503' || code == '23502') {
    return const DatabaseFailure(
      'Data tidak valid. Periksa isian lalu coba lagi.',
    );
  }

  return const DatabaseFailure('Gagal memproses data. Coba lagi.');
}
