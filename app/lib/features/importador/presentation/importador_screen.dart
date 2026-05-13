import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../clientes/data/cliente_repository.dart';
import '../../clientes/presentation/clientes_controller.dart';
import '../domain/excel_importer.dart';
import '../domain/fila_importacion.dart';

class ImportadorScreen extends ConsumerStatefulWidget {
  const ImportadorScreen({super.key});

  @override
  ConsumerState<ImportadorScreen> createState() => _ImportadorScreenState();
}

class _ImportadorScreenState extends ConsumerState<ImportadorScreen> {
  List<FilaImportacion>? _filas;
  String? _nombreArchivo;
  String? _error;
  bool _cargando = false;
  bool _importando = false;

  Future<void> _seleccionarArchivo() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (result == null) {
        setState(() => _cargando = false);
        return;
      }
      final bytes = result.files.first.bytes;
      if (bytes == null) {
        throw const FormatException('No se pudo leer el archivo');
      }

      final filas = ExcelImporter.parsear(bytes);

      // Cargar codigos existentes y proximo libre.
      final repo = ref.read(clienteRepositoryProvider);
      final existentes = await repo.list();
      final codigosUsados = existentes.map((s) => s.codigo).toSet();
      final siguiente = await repo.nextCodigo();

      ExcelImporter.validar(
        filas,
        codigosExistentes: codigosUsados,
        siguienteCodigoLibre: siguiente,
      );

      if (!mounted) return;
      setState(() {
        _filas = filas;
        _nombreArchivo = result.files.first.name;
        _cargando = false;
      });
    } catch (e, stack) {
      appLogger.e('Error leyendo archivo Excel', error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _cargando = false;
      });
    }
  }

  Future<void> _importar() async {
    final filas = _filas;
    if (filas == null) return;
    final validas = filas.where((f) => f.esValida).toList();
    if (validas.isEmpty) return;

    final ok = await confirm(
      context,
      titulo: 'Confirmar importación',
      mensaje:
          'Se crearán ${pluralES(validas.length, "cliente", "clientes")} nuevos. '
          'Las filas con errores serán omitidas.',
      confirmar: 'Importar',
      icono: Icons.upload_file,
    );
    if (!ok) return;

    setState(() => _importando = true);
    final repo = ref.read(clienteRepositoryProvider);
    var creados = 0;
    final errores = <String>[];
    try {
      for (final f in validas) {
        try {
          await repo.create(
            codigo: f.codigo!,
            cedula: f.cedula!.trim(),
            nombre: f.nombre!.trim(),
            direccion: f.direccion,
            telefono: f.telefono,
            sector: f.sector,
            zona: f.zona,
            barrio: f.barrio,
            tarifaMensual: f.tarifa!,
            deudaInicial: f.deudaInicial ?? 0,
            notas: f.notas,
          );
          creados++;
        } catch (e) {
          errores.add('Fila ${f.indiceFila}: $e');
        }
      }
      ref.invalidate(clientesListProvider);
      if (!mounted) return;
      AppSnackbar.success(
        context,
        '${pluralES(creados, "cliente importado", "clientes importados")}'
        '${errores.isEmpty ? '' : ' (${errores.length} con error)'}',
      );
      if (errores.isEmpty) {
        context.go('/clientes');
      } else {
        // Mostrar errores
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Errores durante la importación'),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$creados de ${validas.length} se importaron correctamente.',
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(errores.join('\n')),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filas = _filas;
    final validas = filas?.where((f) => f.esValida).length ?? 0;
    final invalidas = filas == null ? 0 : (filas.length - validas);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Volver',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/clientes'),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  'Importar clientes',
                  style: theme.textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Instrucciones(),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: _cargando || _importando
                                      ? null
                                      : _seleccionarArchivo,
                                  icon: _cargando
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.upload_file),
                                  label: Text(
                                    _cargando
                                        ? 'Cargando...'
                                        : 'Seleccionar Excel',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (_nombreArchivo != null)
                                  Expanded(
                                    child: Text(
                                      _nombreArchivo!,
                                      style: theme.textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(_error!)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (filas != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _Stat(
                                label: 'Filas leídas',
                                value: '${filas.length}',
                              ),
                              const SizedBox(width: 32),
                              _Stat(
                                label: 'Válidas',
                                value: '$validas',
                                color: AppSemanticColors.success(context),
                              ),
                              const SizedBox(width: 32),
                              _Stat(
                                label: 'Con errores',
                                value: '$invalidas',
                                color: invalidas > 0
                                    ? theme.colorScheme.error
                                    : null,
                              ),
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: _importando || validas == 0
                                    ? null
                                    : _importar,
                                icon: _importando
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check),
                                label: Text(
                                  _importando
                                      ? 'Importando...'
                                      : 'Importar $validas',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TablaPreview(filas: filas),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Instrucciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Formato del archivo', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'El archivo debe ser .xlsx con encabezado en la primera fila '
              'y estos nombres de columna (en minúsculas, sin tildes):',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                ExcelImporter.columnasEsperadas.join('  |  '),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Obligatorias en cada fila: cedula, nombre, direccion, tarifa.\n'
              '• Si dejas codigo vacío, se auto-asigna el siguiente consecutivo.\n'
              '• Opcionales (pueden quedar vacías): telefono, sector, zona, barrio, notas.\n'
              '• deuda_inicial es el saldo previo al sistema (queda como factura inicial pendiente — feature futura, hoy se guarda como referencia).',
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _TablaPreview extends StatelessWidget {
  const _TablaPreview({required this.filas});
  final List<FilaImportacion> filas;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Fila')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Código'), numeric: true),
              DataColumn(label: Text('Cédula')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Dirección')),
              DataColumn(label: Text('Sector')),
              DataColumn(label: Text('Tarifa'), numeric: true),
              DataColumn(label: Text('Deuda inicial'), numeric: true),
              DataColumn(label: Text('Errores')),
            ],
            rows: [
              for (final f in filas)
                DataRow(
                  color: WidgetStatePropertyAll(
                    f.esValida
                        ? null
                        : Theme.of(
                            context,
                          ).colorScheme.errorContainer.withValues(alpha: 0.4),
                  ),
                  cells: [
                    DataCell(Text('${f.indiceFila + 1}')),
                    DataCell(
                      Icon(
                        f.esValida ? Icons.check_circle : Icons.error_outline,
                        color: f.esValida
                            ? AppSemanticColors.success(context)
                            : Theme.of(context).colorScheme.error,
                        size: 18,
                        semanticLabel: f.esValida ? 'Válida' : 'Con errores',
                      ),
                    ),
                    DataCell(Text(f.codigo == null ? '—' : '${f.codigo}')),
                    DataCell(Text(f.cedula ?? '—')),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          f.nombre ?? '—',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Text(
                          f.direccion ?? '—',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(f.sector ?? '—')),
                    DataCell(
                      Text(f.tarifa == null ? '—' : formatPesos(f.tarifa!)),
                    ),
                    DataCell(
                      Text(
                        (f.deudaInicial ?? 0) == 0
                            ? '—'
                            : formatPesos(f.deudaInicial!),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 220,
                        child: Text(
                          f.errores.join(' · '),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
