import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Variantes semánticas para [StatusChip]. Cada variante mapea a colores
/// del theme (light/dark) garantizando contraste.
enum StatusVariant { success, warning, danger, info, neutral }

/// Chip de estado consistente para todas las listas (cliente activo/retirado,
/// factura pendiente/pagada/anulada, dano reportado/reparado, etc.).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.variant,
    this.icon,
    this.compact = false,
  });

  final String label;
  final StatusVariant variant;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (variant) {
      StatusVariant.success => AppSemanticColors.success(context),
      StatusVariant.warning => AppSemanticColors.warning(context),
      StatusVariant.danger => AppSemanticColors.danger(context),
      StatusVariant.info => AppSemanticColors.info(context),
      StatusVariant.neutral => AppSemanticColors.neutral(context),
    };
    final bg = switch (variant) {
      StatusVariant.success => AppSemanticColors.successContainer(context),
      StatusVariant.warning => AppSemanticColors.warningContainer(context),
      StatusVariant.danger => AppSemanticColors.dangerContainer(context),
      StatusVariant.info => AppSemanticColors.infoContainer(context),
      StatusVariant.neutral => AppSemanticColors.neutralContainer(context),
    };
    final fg = switch (variant) {
      StatusVariant.danger => theme.colorScheme.onErrorContainer,
      StatusVariant.info => theme.colorScheme.onPrimaryContainer,
      _ => color,
    };
    return Semantics(
      label: 'Estado: $label',
      container: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
          vertical: compact ? 2 : AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 12 : 14, color: fg),
              SizedBox(width: compact ? 4 : AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
