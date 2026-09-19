// lib/main.dart
// Entry point aplikasi Hari Baik
// - Load .env via flutter_dotenv
// - Inisialisasi Supabase dari env (bukan hardcode)
// - Error handler global (FlutterError, PlatformDispatcher, runZonedGuarded)
// - ErrorWidget.builder (ganti layar merah)
// - AuthGate: cek session → MainShell atau LoginScreen

import 'dart:async';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth/login_screen.dart';
import 'screens/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia untuk DateFormat
  await initializeDateFormatting('id_ID', null);

  // Error handler global — ganti layar merah (PRD 8.7)
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}\n${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformError: $error\n$stack');
    return true;
  };

  ErrorWidget.builder = (details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan tampilan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // runZonedGuarded untuk menangkap error async yang lolos (PRD 8.7)
  runZonedGuarded(() async {
    try {
      await dotenv.load(fileName: '.env');

      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (url == null ||
          anonKey == null ||
          url.isEmpty ||
          anonKey.isEmpty) {
        runApp(const _ConfigErrorApp());
        return;
      }

      await Supabase.initialize(url: url, publishableKey: anonKey);
      runApp(const HariBaikApp());
    } catch (e) {
      debugPrint('Init error: $e');
      runApp(const _ConfigErrorApp());
    }
  }, (error, stack) {
    debugPrint('Uncaught async error: $error\n$stack');
  });
}

// ─── Layar error konfigurasi ───────────────────────────────────────────
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_suggest, size: 64, color: Colors.orange.shade700),
                const SizedBox(height: 16),
                const Text(
                  'Konfigurasi aplikasi belum lengkap',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan file .env berisi SUPABASE_URL dan SUPABASE_ANON_KEY yang valid.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── App utama ─────────────────────────────────────────────────────────
class HariBaikApp extends StatelessWidget {
  const HariBaikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hari Baik',
      debugShowCheckedModeBanner: false,
      // Tema Material 3 nuansa Jawa — cokelat/emas (PRD 9)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5E3C), // warm brown
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Locale Indonesia untuk DatePicker dll.
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}

// ─── Auth Gate ─────────────────────────────────────────────────────────
// Cek session: ada → MainShell, tidak ada → LoginScreen (PRD F1)
// Dengarkan onAuthStateChange untuk pindah ke Login saat sesi berakhir.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      if (data.event == AuthChangeEvent.signedOut) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berakhir. Silakan login kembali.'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) return const MainShell();
    return const LoginScreen();
  }
}
