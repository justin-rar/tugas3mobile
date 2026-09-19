// lib/utils/kalender_util.dart
// Logika murni Dart (tanpa package) untuk: weton, wuku, Saka Bali, umur, hari baik.
// Untuk Hijriah pakai package `hijri` (lihat catatan di bawah).

class Weton {
  final String hari;
  final String pasaran;
  final int neptuHari;
  final int neptuPasaran;
  final String wuku;
  int get neptu => neptuHari + neptuPasaran;
  String get teks => '$hari $pasaran';
  Weton(this.hari, this.pasaran, this.neptuHari, this.neptuPasaran, this.wuku);
}

class SakaBali {
  final int tahunSaka;
  final String saptawara;
  final String pancawara;
  final String wuku;
  SakaBali(this.tahunSaka, this.saptawara, this.pancawara, this.wuku);
}

class Umur {
  final int tahun, bulan, hari, jam, menit, detik;
  Umur(this.tahun, this.bulan, this.hari, this.jam, this.menit, this.detik);
}

class HasilHariBaik {
  final int sisa;
  final String nama;
  final bool baik;
  HasilHariBaik(this.sisa, this.nama, this.baik);
}

class KalenderUtil {
  // Acuan: 21 Mei 2000 = Minggu Pahing = awal Wuku Sinta
  static final DateTime _epoch = DateTime.utc(2000, 5, 21);

  static const List<String> wuku = [
    'Sinta', 'Landep', 'Wukir', 'Kurantil', 'Tolu', 'Gumbreg',
    'Warigalit', 'Warigagung', 'Julungwangi', 'Sungsang', 'Galungan',
    'Kuningan', 'Langkir', 'Mandhasiya', 'Julung Pujud', 'Pahang',
    'Kuruwelut', 'Marakeh', 'Tambir', 'Medangkungan', 'Maktal', 'Wuye',
    'Manahil', 'Prangbakat', 'Bala', 'Wugu', 'Wayang', 'Kulawu', 'Dukut',
    'Watugunung',
  ];

  static const List<String> pasaran = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];
  static const List<int> _nilaiPasaran = [5, 9, 7, 4, 8];

  // Index 0 = Senin ... 6 = Minggu (DateTime.weekday - 1)
  static const List<String> namaHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];
  static const List<int> _nilaiHari = [4, 3, 7, 8, 6, 9, 5];

  // Padanan Bali
  static const List<String> _saptawaraBali = [
    'Soma', 'Anggara', 'Buda', 'Wraspati', 'Sukra', 'Saniscara', 'Redite'
  ];
  static const List<String> _pancawaraBali = [
    'Umanis', 'Paing', 'Pon', 'Wage', 'Kaliwon'
  ];

  // Tanggal Nyepi (awal tahun Saka). VERIFIKASI ulang sebelum dikumpulkan.
  static final Map<int, DateTime> _nyepi = {
    2024: DateTime.utc(2024, 3, 11),
    2025: DateTime.utc(2025, 3, 29),
    2026: DateTime.utc(2026, 3, 19),
    2027: DateTime.utc(2027, 3, 9),
  };

  static int _selisihHari(DateTime tgl) {
    final d = DateTime.utc(tgl.year, tgl.month, tgl.day);
    return d.difference(_epoch).inDays;
  }

  static Weton hitungWeton(DateTime tgl) {
    final selisih = _selisihHari(tgl);
    final idxWuku = (selisih % 210) ~/ 7; // Dart: % selalu >= 0
    final idxPasaran = (selisih + 1) % 5; // +1 karena epoch = Pahing
    final idxHari = tgl.weekday - 1;
    return Weton(
      namaHari[idxHari],
      pasaran[idxPasaran],
      _nilaiHari[idxHari],
      _nilaiPasaran[idxPasaran],
      wuku[idxWuku],
    );
  }

  static SakaBali hitungSakaBali(DateTime tgl) {
    final selisih = _selisihHari(tgl);
    final nyepi = _nyepi[tgl.year];
    // Tahun Saka: Masehi - 78 setelah Nyepi, Masehi - 79 sebelum Nyepi
    // Jika tahun tidak ada di tabel, anggap Nyepi jatuh 15 Maret (perkiraan).
    final batas = nyepi ?? DateTime.utc(tgl.year, 3, 15);
    final tglUtc = DateTime.utc(tgl.year, tgl.month, tgl.day);
    final tahunSaka = tglUtc.isBefore(batas) ? tgl.year - 79 : tgl.year - 78;
    return SakaBali(
      tahunSaka,
      _saptawaraBali[tgl.weekday - 1],
      _pancawaraBali[(selisih + 1) % 5],
      wuku[(selisih % 210) ~/ 7],
    );
  }

  // Umur lengkap sampai detik
  static Umur hitungUmur(DateTime lahir, DateTime sekarang) {
    int detik = sekarang.second - lahir.second;
    int menit = sekarang.minute - lahir.minute;
    int jam = sekarang.hour - lahir.hour;
    int hari = sekarang.day - lahir.day;
    int bulan = sekarang.month - lahir.month;
    int tahun = sekarang.year - lahir.year;

    if (detik < 0) { detik += 60; menit--; }
    if (menit < 0) { menit += 60; jam--; }
    if (jam < 0) { jam += 24; hari--; }
    if (hari < 0) {
      hari += DateTime(sekarang.year, sekarang.month, 0).day; // hari di bulan sebelumnya
      bulan--;
    }
    if (bulan < 0) { bulan += 12; tahun--; }
    return Umur(tahun, bulan, hari, jam, menit, detik);
  }

  // Komputasi hari baik: total neptu mod 8 (sisa 0 dianggap 8)
  static const List<String> _namaMod8 = [
    'Pegat', 'Ratu', 'Jodoh', 'Topo', 'Tinari', 'Padu', 'Sujanan', 'Pesthi'
  ];
  static const Set<int> _sisaBaik = {2, 3, 5, 6, 8};

  static HasilHariBaik cekTotalNeptu(int totalNeptu) {
    int sisa = totalNeptu % 8;
    if (sisa == 0) sisa = 8;
    return HasilHariBaik(sisa, _namaMod8[sisa - 1], _sisaBaik.contains(sisa));
  }

  // Kecocokan dua orang: neptu A + neptu B
  static HasilHariBaik kecocokan(DateTime lahirA, DateTime lahirB) {
    return cekTotalNeptu(hitungWeton(lahirA).neptu + hitungWeton(lahirB).neptu);
  }

  // Cek tanggal acara untuk seseorang: neptu orang + neptu tanggal acara
  static HasilHariBaik cekHariAcara(DateTime lahirOrang, DateTime tglAcara) {
    return cekTotalNeptu(hitungWeton(lahirOrang).neptu + hitungWeton(tglAcara).neptu);
  }
}

// ---------------------------------------------------------------
// Hijriah (pubspec.yaml: hijri: ^3.0.0 -> cek versi terbaru di pub.dev)
//
//   import 'package:hijri/hijri_calendar.dart';
//   final h = HijriCalendar.fromDate(DateTime.now());
//   Text('${h.hDay} ${h.longMonthName} ${h.hYear} H');
//
// Catatan: hasil bisa selisih 1 hari dari penetapan Kemenag RI. Sebut di laporan.
// ---------------------------------------------------------------
