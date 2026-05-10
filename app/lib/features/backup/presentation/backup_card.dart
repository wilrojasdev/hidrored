import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/backup_service.dart';

/// Card que va dentro de la pantalla de Configuracion. Permite generar un
/// archivo JSON con todos los datos del tenant.
class BackupCard extends ConsumerStatefulWidget {
  const BackupCard({super.key});

  @override
  ConsumerState<BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends ConsumerState<BackupCard> {
  bool _generando = false;

  Future<bool> _confirmar() {
    return confirm(
      context,
      titulo: 'Generar backup',
      mensaje:
          'El archivo contiene información sensible: datos personales de los '
          'clientes, facturas, pagos y cuentas bancarias del acueducto. '
          'Guárdalo en un lugar seguro y no lo compartas con personas no '
          'autorizadas.',
      confirmar: 'Continuar',
      icono: Icons.security_outlined,
    );
  }

  Future<void> _exportar() async {
    if (!await _confirmar()) return;
    if (!mounted) return;
    setState(() => _generando = true);
    try {
      final service = await ref.read(backupServiceProvider.future);
      final result = await service.exportar();

      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        // Compartir via share sheet
        await Share.shareXFiles([
          XFile.fromData(
            result.bytes,
            name: result.filename,
            mimeType: 'application/json',
          ),
        ], subject: 'Backup hidrored');
      } else {
        // Desktop: dialog "Guardar como"
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar backup',
          fileName: result.filename,
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: result.bytes,
        );
        if (path == null) {
          if (!mounted) return;
          return;
        }
        // En Linux/macOS/Windows, FilePicker.saveFile puede o no escribir
        // segun la version. Como fallback, escribimos manualmente.
        final f = File(path);
        if (!f.existsSync() || f.lengthSync() == 0) {
          await f.writeAsBytes(result.bytes);
        }
      }

      if (!mounted) return;
      AppSnackbar.success(context, 'Backup generado: ${result.filename}');
    } catch (e, stack) {
      appLogger.e('Error generando backup', error: e, stackTrace: stack);
      if (!mounted) return;
      AppSnackbar.error(context, e);
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup local',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.gapXs,
            Text(
              'Descarga un archivo JSON con todos los datos del acueducto '
              '(clientes, conceptos, facturas, pagos, eventos, daños). '
              'Contiene información sensible: guárdalo en lugar seguro.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _generando ? null : _exportar,
                  icon: _generando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(_generando ? 'Generando...' : 'Exportar backup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
