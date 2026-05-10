import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum ConfirmTone { neutral, danger }

/// Diálogo de confirmación reutilizable. Devuelve `true` si el usuario
/// confirma, `false` o `null` si cancela. La acción peligrosa usa color
/// de error.
Future<bool> confirm(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String confirmar = 'Confirmar',
  String cancelar = 'Cancelar',
  ConfirmTone tone = ConfirmTone.neutral,
  IconData? icono,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final danger = tone == ConfirmTone.danger;
      return AlertDialog(
        icon: icono == null
            ? null
            : Icon(
                icono,
                color: danger ? theme.colorScheme.error : null,
                size: 32,
              ),
        title: Text(titulo),
        content: Text(mensaje),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelar),
          ),
          if (danger)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmar),
            )
          else
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmar),
            ),
        ],
      );
    },
  );
  return result == true;
}

/// Pregunta al usuario si quiere descartar cambios sin guardar. Útil dentro
/// de `PopScope` en formularios.
Future<bool> confirmDiscardChanges(BuildContext context) {
  return confirm(
    context,
    titulo: '¿Descartar cambios?',
    mensaje: 'Si sales ahora perderás los datos que cambiaste. ¿Estás seguro?',
    confirmar: 'Descartar',
    cancelar: 'Seguir editando',
    tone: ConfirmTone.danger,
    icono: Icons.warning_amber_rounded,
  );
}
