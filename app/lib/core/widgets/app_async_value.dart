import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/error_messages.dart';
import '../theme/app_spacing.dart';

/// Helper para renderizar AsyncValue de forma uniforme en toda la app.
/// Muestra skeleton/spinner mientras carga, mensaje de error con boton de
/// retry, y delega al `data` builder cuando hay datos.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final VoidCallback? onRetry;

  /// Widget custom de carga. Si es null se usa un CircularProgressIndicator
  /// centrado.
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (err, _) => ErrorBox(error: err, onRetry: onRetry),
    );
  }
}

class ErrorBox extends StatelessWidget {
  const ErrorBox({super.key, required this.error, this.onRetry})
    : message = null;

  /// Constructor compatibilidad: pasar mensaje crudo.
  const ErrorBox.message({
    super.key,
    required String this.message,
    this.onRetry,
  }) : error = null;

  final Object? error;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mensaje = message ?? (error == null ? '' : userMessageFor(error!));
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
                semanticLabel: 'Error',
              ),
              AppSpacing.gapMd,
              Text(
                'Algo salió mal',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapXs,
              Text(
                mensaje,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                AppSpacing.gapLg,
                FilledButton.tonalIcon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
