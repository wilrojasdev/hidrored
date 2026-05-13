import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../domain/enums.dart';
import '../domain/billing_service.dart';
import '../domain/preview_facturacion.dart';
import 'facturas_controller.dart';

class GenerarFacturacionScreen extends ConsumerStatefulWidget {
  const GenerarFacturacionScreen({super.key});

  @override
  ConsumerState<GenerarFacturacionScreen> createState() =>
      _GenerarFacturacionScreenState();
}

class _GenerarFacturacionScreenState
    extends ConsumerState<GenerarFacturacionScreen> {
  late DateTime _fechaEmision;
  String _periodo = '';

  List<PreviewFacturaCliente>? _preview;
  bool _calculando = false;
  bool _ejecutando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = BogotaClock.hoy();
    final ultimoDia = DateTime(now.year, now.month + 1, 0);
    _fechaEmision = ultimoDia;
    _periodo = _toPeriodo(now);
  }

  String _toPeriodo(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  Future<void> _calcularPreview() async {
    setState(() {
      _calculando = true;
      _error = null;
      _preview = null;
    });
    try {
      final service = await ref.read(billingServiceProvider.future);
      final preview = await service.previewFacturacion(
        periodo: _periodo,
        fechaEmision: _fechaEmision,
      );
      if (mounted) setState(() => _preview = preview);
    } catch (e, stack) {
      appLogger.e('Error calculando preview', error: e, stackTrace: stack);
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _calculando = false);
    }
  }

  Future<void> _ejecutar() async {
    final cantidad = _preview!.where((p) => p.tieneCargos).length;
    final total = _preview!.fold<int>(0, (s, p) => s + p.totalRecibo);
    final conRefacturadas =
        _preview!.where((p) => p.cantidadRefacturadas > 0).length;
    final mensaje = StringBuffer(
      'Se emitirán ${pluralES(cantidad, "factura", "facturas")} '
      'para ${formatPeriodo(_periodo)}.\n\n'
      'Total facturado: ${formatPesos(total)}\n\n',
    );
    if (conRefacturadas > 0) {
      mensaje.write(
        '$conRefacturadas '
        '${pluralES(conRefacturadas, "cliente tendrá saldos anteriores absorbidos en su nueva factura.", "clientes tendrán saldos anteriores absorbidos en sus nuevas facturas.")}'
        '\n\n',
      );
    }
    mensaje.write(
      'Esta acción genera los recibos del mes. Si necesitas corregir '
      'algo después, puedes anular y los saldos refacturados volverán a '
      'estar pendientes.',
    );

    final ok = await confirm(
      context,
      titulo: 'Confirmar facturación',
      mensaje: mensaje.toString(),
      confirmar: 'Emitir',
      icono: Icons.playlist_add_check,
    );
    if (!ok) return;

    setState(() {
      _ejecutando = true;
      _error = null;
    });
    try {
      final service = await ref.read(billingServiceProvider.future);
      final creadas = await service.ejecutarFacturacion(
        periodo: _periodo,
        fechaEmision: _fechaEmision,
      );
      ref.invalidate(facturasListProvider);
      ref.invalidate(periodosExistentesProvider);
      if (!mounted) return;
      AppSnackbar.success(
        context,
        pluralES(creadas, 'factura emitida', 'facturas emitidas'),
      );
      context.go('/facturas');
    } catch (e, stack) {
      appLogger.e('Error emitiendo facturación', error: e, stackTrace: stack);
      if (mounted) setState(() => _error = '$e');
      if (mounted) AppSnackbar.error(context, e);
    } finally {
      if (mounted) setState(() => _ejecutando = false);
    }
  }

  Future<void> _seleccionarPeriodo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaEmision,
      firstDate: DateTime(2024),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      helpText: 'Fecha de emisión del recibo',
    );
    if (picked != null) {
      setState(() {
        _fechaEmision = picked;
        _periodo = _toPeriodo(picked);
        _preview = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Volver',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/facturas'),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generar facturación',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text(
                      'Calcula el preview del mes y emite los recibos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapXl,
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tight = constraints.maxWidth < 720;
                      final selectores = [
                        _ParamSelector(
                          icon: Icons.calendar_today,
                          label: 'Periodo',
                          value: formatPeriodo(_periodo),
                          onTap: _calculando || _ejecutando
                              ? null
                              : _seleccionarPeriodo,
                        ),
                        _ParamSelector(
                          icon: Icons.event,
                          label: 'Fecha de emisión',
                          value: formatFecha(_fechaEmision),
                        ),
                      ];
                      final boton = FilledButton.tonalIcon(
                        onPressed: _calculando || _ejecutando
                            ? null
                            : _calcularPreview,
                        icon: _calculando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.calculate_outlined),
                        label: Text(
                          _calculando ? 'Calculando...' : 'Calcular preview',
                        ),
                      );
                      if (tight) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final s in selectores) ...[
                              s,
                              AppSpacing.gapMd,
                            ],
                            boton,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: selectores[0]),
                          AppSpacing.gapMd,
                          Expanded(child: selectores[1]),
                          AppSpacing.gapLg,
                          boton,
                        ],
                      );
                    },
                  ),
                  if (_error != null) ...[
                    AppSpacing.gapMd,
                    ErrorBox.message(message: _error!),
                  ],
                ],
              ),
            ),
          ),
          AppSpacing.gapLg,
          if (_preview != null)
            Expanded(child: _PreviewTable(preview: _preview!)),
          if (_preview != null) ...[
            AppSpacing.gapLg,
            _Footer(
              preview: _preview!,
              ejecutando: _ejecutando,
              onEjecutar: _ejecutar,
            ),
          ],
        ],
      ),
    );
  }
}

class _ParamSelector extends StatelessWidget {
  const _ParamSelector({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = onTap != null;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (interactive)
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewTable extends StatefulWidget {
  const _PreviewTable({required this.preview});
  final List<PreviewFacturaCliente> preview;

  @override
  State<_PreviewTable> createState() => _PreviewTableState();
}

class _PreviewTableState extends State<_PreviewTable> {
  // Controllers explícitos: el bug anterior ("Scrollbar's ScrollController has
  // no ScrollPosition attached") salía porque el Scrollbar default trataba de
  // adjuntarse al PrimaryScrollController y había dos Scrollables anidados
  // (vertical y horizontal). Con controllers separados cada Scrollbar sabe
  // exactamente a qué Scrollable adherirse.
  final _vCtrl = ScrollController();
  final _hCtrl = ScrollController();

  @override
  void dispose() {
    _vCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    final theme = Theme.of(context);
    if (preview.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: Text(
              'No hay clientes activos para este periodo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _vCtrl,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _vCtrl,
          child: Scrollbar(
            controller: _hCtrl,
            thumbVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              controller: _hCtrl,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                dataTextStyle: theme.textTheme.bodyMedium,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Cliente')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Mensualidad'), numeric: true),
                  DataColumn(label: Text('Mora'), numeric: true),
                  DataColumn(label: Text('Reconexión'), numeric: true),
                  DataColumn(label: Text('Extras'), numeric: true),
                  DataColumn(label: Text('Refacturado'), numeric: true),
                  DataColumn(label: Text('Recibo'), numeric: true),
                ],
                rows: [
                  for (final p in preview)
                    DataRow(
                      cells: [
                        DataCell(Text('${p.cliente.codigo}')),
                        DataCell(
                          SizedBox(
                            width: 200,
                            child: Text(
                              p.cliente.nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          p.tipo == TipoFactura.mensual
                              ? const Text('Mensual')
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusPill,
                                    ),
                                  ),
                                  child: Text(
                                    'Recordatorio',
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                        ),
                        DataCell(Text(formatPesos(p.valorMensualidad))),
                        DataCell(Text(formatPesos(p.valorMora))),
                        DataCell(Text(formatPesos(p.costoReconexion))),
                        DataCell(
                          Text(
                            p.cargosExtras.isEmpty
                                ? '-'
                                : '${p.cargosExtras.length}× ${formatPesos(p.totalCargosExtras)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            p.cantidadRefacturadas == 0
                                ? '-'
                                : '${p.cantidadRefacturadas}× ${formatPesos(p.totalRefacturado)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            formatPesos(p.totalRecibo),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.preview,
    required this.ejecutando,
    required this.onEjecutar,
  });

  final List<PreviewFacturaCliente> preview;
  final bool ejecutando;
  final VoidCallback onEjecutar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paraEmitir = preview.where((p) => p.tieneCargos).length;
    final totalRefacturado = preview.fold<int>(
      0,
      (s, p) => s + p.totalRefacturado,
    );
    final totalRecibos = preview.fold<int>(0, (s, p) => s + p.totalRecibo);
    final totalNuevo = totalRecibos - totalRefacturado;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _FooterStat(label: 'Recibos a emitir', value: '$paraEmitir'),
            const SizedBox(width: 32),
            _FooterStat(
              label: 'Cargos del mes',
              value: formatPesos(totalNuevo),
              hint: 'Mensualidades + mora + reconexiones + extras',
            ),
            const SizedBox(width: 32),
            _FooterStat(
              label: 'Refacturado',
              value: formatPesos(totalRefacturado),
              hint: 'Saldos absorbidos de meses anteriores',
            ),
            const SizedBox(width: 32),
            _FooterStat(
              label: 'Total a cobrar',
              value: formatPesos(totalRecibos),
              valueStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: ejecutando || paraEmitir == 0 ? null : onEjecutar,
              icon: ejecutando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(ejecutando ? 'Emitiendo...' : 'Confirmar y emitir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  const _FooterStat({
    required this.label,
    required this.value,
    this.hint,
    this.valueStyle,
  });

  final String label;
  final String value;
  final String? hint;
  final TextStyle? valueStyle;

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
          style:
              valueStyle ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        if (hint != null)
          Text(
            hint!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
