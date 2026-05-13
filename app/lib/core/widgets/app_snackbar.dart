import 'package:flutter/material.dart';

import '../errors/error_messages.dart';

/// Helpers para mostrar SnackBars consistentes (color, ícono, duración).
class AppSnackbar {
  const AppSnackbar._();

  static void success(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: scheme.inverseSurface,
      foregroundColor: scheme.onInverseSurface,
    );
  }

  static void info(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: scheme.inverseSurface,
      foregroundColor: scheme.onInverseSurface,
    );
  }

  static void error(BuildContext context, Object error) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: userMessageFor(error),
      icon: Icons.error_outline,
      backgroundColor: scheme.error,
      foregroundColor: scheme.onError,
    );
  }

  static void errorMessage(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: scheme.error,
      foregroundColor: scheme.onError,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foregroundColor)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
