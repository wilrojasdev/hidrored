import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Banner persistente cuando el dispositivo no tiene red. La app sigue
/// usable para acciones locales (vista previa de PDFs) pero las que
/// tocan Supabase (cargar listas, registrar pagos, generar facturación)
/// fallarán. El admin debe esperar a recuperar conexión.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      label:
          'Sin conexión a internet. Algunas acciones no funcionarán hasta '
          'que se restablezca la red.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.cloud_off,
                size: 14,
                color: theme.colorScheme.onErrorContainer,
                semanticLabel: 'Sin conexión',
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: Text(
                'Sin conexión. Algunas acciones no estarán disponibles hasta '
                'restablecer la red.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pequeña insignia para mostrar a un lado de un título o registro
/// indicando que aún no se ha sincronizado al servidor. Por ahora la
/// usamos para señalar de forma genérica que "algunos datos pueden no
/// estar al día" cuando el dispositivo está offline; al integrar
/// PowerSync con estado de sync por fila pasaremos un bool real.
class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, this.tooltip = 'Pendiente de sincronizar'});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            Icons.sync_problem,
            size: 12,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
