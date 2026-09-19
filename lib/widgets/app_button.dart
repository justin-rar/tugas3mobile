// lib/widgets/app_button.dart

import 'package:flutter/material.dart';

/// Tombol reusable yang otomatis disabled dan menampilkan loading saat proses.
/// Mencegah double submit (PRD 8.1 poin 4).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isDestructive;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final style = isDestructive
        ? FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          )
        : null;

    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    if (icon != null && !isLoading) {
      return FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }
}
