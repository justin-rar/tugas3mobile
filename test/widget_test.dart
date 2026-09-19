import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:tugas3/screens/kalender/kalender_screen.dart';
import 'package:tugas3/screens/hijriah/hijriah_screen.dart';
import 'package:tugas3/screens/umur/umur_screen.dart';
import 'package:tugas3/utils/kalender_util.dart';
import 'package:tugas3/utils/validators.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Validators.nama', () {
    test('Nama valid dengan petik, angka, titik, strip', () {
      expect(Validators.nama("Ma'aruf"), isNull);
      expect(Validators.nama("M. Ma'aruf"), isNull);
      expect(Validators.nama("Siti-Aminah"), isNull);
      expect(Validators.nama("Ahmad 123"), isNull);
    });

    test('Nama tidak valid jika terlalu pendek, terlalu panjang, atau simbol liar', () {
      expect(Validators.nama(""), isNotNull);
      expect(Validators.nama("A"), isNotNull);
      expect(Validators.nama("Nama Ini Sangat Panjang Melebihi Batas Tiga Puluh Karakter"), isNotNull);
      expect(Validators.nama("Ma'aruf<script>"), isNotNull);
      expect(Validators.nama("User@123"), isNotNull);
    });
  });

  group('Kalender & Date Logic', () {
    test('Format tanggal dan kalender Hijriah', () {
      final now = DateTime.now();
      final formatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
      expect(formatted.isNotEmpty, isTrue);

      final h = HijriCalendar.fromDate(now);
      expect(h.hYear > 1400, isTrue);
    });

    test('Hitung weton untuk tanggal lampau dan sekarang', () {
      final past = DateTime(1995, 5, 10);
      final pastWeton = KalenderUtil.hitungWeton(past);
      expect(pastWeton.hari, equals('Rabu'));
      expect(pastWeton.pasaran, equals('Wage'));

      final nowWeton = KalenderUtil.hitungWeton(DateTime.now());
      expect(nowWeton.hari.isNotEmpty, isTrue);
      expect(nowWeton.pasaran.isNotEmpty, isTrue);
    });

    test('Hitung umur', () {
      final umur = KalenderUtil.hitungUmur(DateTime(2000, 1, 1), DateTime(2026, 1, 1));
      expect(umur.tahun, equals(26));
    });
  });

  group('Widget & Localization UI Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        locale: const Locale('id', 'ID'),
        home: child,
      );
    }

    testWidgets('DatePicker dengan locale Indonesia dapat dibuka', (tester) async {
      BuildContext? testContext;
      await tester.pumpWidget(buildTestApp(Scaffold(
        body: Builder(
          builder: (ctx) {
            testContext = ctx;
            return const SizedBox();
          },
        ),
      )));

      showDatePicker(
        context: testContext!,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: const Locale('id', 'ID'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('Render KalenderScreen, HijriahScreen, UmurScreen', (tester) async {
      await tester.pumpWidget(buildTestApp(const KalenderScreen()));
      expect(find.byType(KalenderScreen), findsOneWidget);

      await tester.pumpWidget(buildTestApp(const HijriahScreen()));
      expect(find.byType(HijriahScreen), findsOneWidget);

      await tester.pumpWidget(buildTestApp(const UmurScreen()));
      expect(find.byType(UmurScreen), findsOneWidget);
    });
  });
}
