// lib/core/constants.dart

class AppConstants {
  AppConstants._();

  /// Timeout untuk semua panggilan jaringan (PRD 8.1 poin 5)
  static const Duration timeout = Duration(seconds: 15);

  /// Pilihan jenis acara (PRD F5)
  static const List<String> jenisAcara = [
    'Pernikahan',
    'Pindah Rumah',
    'Usaha',
    'Lainnya',
  ];
}
