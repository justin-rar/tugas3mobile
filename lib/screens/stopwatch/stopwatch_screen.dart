// lib/screens/stopwatch/stopwatch_screen.dart
// Stopwatch dengan Start/Pause, Reset, Lap (PRD F9)

import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() {});
  }

  void _reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    setState(() => _laps.clear());
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      setState(() => _laps.insert(0, _stopwatch.elapsed));
    }
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final cs =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$mm:$ss.$cs';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = _stopwatch.isRunning;

    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          const SizedBox(height: 40),

          // Tampilan waktu
          Text(
            _format(_stopwatch.elapsed),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 32),

          // Tombol kontrol
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              FilledButton.tonal(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),

              // Start / Pause
              FilledButton(
                onPressed: _startStop,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isRunning ? colorScheme.error : colorScheme.primary,
                  foregroundColor:
                      isRunning ? colorScheme.onError : colorScheme.onPrimary,
                  minimumSize: const Size(120, 48),
                ),
                child: Text(isRunning ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 16),

              // Lap
              FilledButton.tonal(
                onPressed: isRunning ? _lap : null,
                child: const Text('Lap'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Daftar lap
          if (_laps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Lap',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Waktu',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemBuilder: (context, index) {
                final lapNum = _laps.length - index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        'Lap $lapNum',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        _format(_laps[index]),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
