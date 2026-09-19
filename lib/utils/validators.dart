// lib/utils/validators.dart
// Validasi input sesuai PRD 8.4

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi.';
    }
    final trimmed = value.trim();
    // Regex sederhana
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(trimmed)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi.';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter.';
    }
    return null;
  }

  static String? konfirmasiPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }
    if (value != password) {
      return 'Password tidak cocok.';
    }
    return null;
  }

  static String? nama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi.';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Nama minimal 2 karakter.';
    }
    if (trimmed.length > 30) {
      return 'Nama maksimal 30 karakter.';
    }
    final validCharRegex = RegExp(r"^[a-zA-Z0-9\s'.-]+$");
    if (!validCharRegex.hasMatch(trimmed)) {
      return 'Nama hanya boleh berisi huruf, angka, spasi, petik satu (\'), titik, atau tanda hubung.';
    }
    return null;
  }

  static String? tanggalLahir(DateTime? value) {
    if (value == null) {
      return 'Tanggal lahir wajib diisi.';
    }
    if (value.isAfter(DateTime.now())) {
      return 'Tanggal lahir tidak boleh di masa depan.';
    }
    if (value.isBefore(DateTime(1900, 1, 1))) {
      return 'Tanggal lahir tidak valid.';
    }
    return null;
  }

  static String? tanggalAcara(DateTime? value) {
    if (value == null) {
      return 'Tanggal acara wajib diisi.';
    }
    if (value.isBefore(DateTime(1900, 1, 1))) {
      return 'Tanggal acara tidak valid.';
    }
    if (value.isAfter(DateTime(2100, 12, 31))) {
      return 'Tanggal acara tidak valid.';
    }
    return null;
  }

  static String? jenisAcara(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jenis acara wajib dipilih.';
    }
    return null;
  }
}
