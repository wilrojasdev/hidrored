import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Estado vacío reutilizable con ícono, título, descripción y CTAs.
/// Reemplaza los `_EmptyState()` duplicados en cada listado.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.titulo,
    this.descripcion,
    this.acciones = const [],
  });

  final IconData icon;
  final String titulo;
  final String? descripcion;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 96,
                color: theme.colorScheme.outline,
                semanticLabel: titulo,
              ),
              AppSpacing.gapLg,
              Text(
                titulo,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (descripcion != null) ...[
                AppSpacing.gapSm,
                Text(
                  descripcion!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (acciones.isNotEmpty) ...[
                AppSpacing.gapXl,
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: acciones,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
