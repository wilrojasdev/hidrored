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
import '../../../domain/entities/cliente.dart';
import '../../cargos/data/cargo_pendiente_repository.dart';
import '../../clientes/presentation/clientes_controller.dart';
import '../domain/billing_service.dart';
import '../domain/preview_facturacion.dart';
import 'facturas_controller.dart';

/// Pantalla para emitir UNA factura para un cliente específico:
/// - Alta tardía (cliente nuevo después de la facturación masiva).
/// - Re-emisión tras anular una factura.
/// - Ajustes puntuales con cargos extras.
class GenerarFacturaIndividualScreen extends ConsumerStatefulWidget {
  const GenerarFacturaIndividualScreen({
    super.key,
    required this.clienteId,
    this.periodoInicial,
  });

  final String clienteId;

  /// Periodo pre-llenado al entrar (útil al re-emitir tras anulación).
  final String? periodoInicial;

  @override
  ConsumerState<GenerarFacturaIndividualScreen> createState() =>
      _GenerarFacturaIndividualScreenState();
}

class _GenerarFacturaIndividualScreenState
    extends ConsumerState<GenerarFacturaIndividualScreen> {
  late DateTime _fechaEmision;
  late String _periodo;

  PreviewFacturaCliente? _preview;
  bool _calculando = false;
  bool _ejecutando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final hoy = BogotaClock.hoy();
    _fechaEmision = DateTime(hoy.year, hoy.month + 1, 0);
    _periodo = widget.periodoInicial ?? _toPeriodo(hoy);
    // Auto-calcular preview al entrar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calcularPreview();
    });
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
      final preview = await service.previewFacturaIndividual(
        clienteId: widget.clienteId,
        periodo: _periodo,
        fechaEmision: _fechaEmision,
      );
      if (mounted) setState(() => _preview = preview);
    } catch (e, stack) {
      appLogger.e('Error preview individual', error: e, stackTrace: stack);
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _calculando = false);
    }
  }

  Future<void> _ejecutar() async {
    final preview = _preview;
    if (preview == null) return;
    final mensaje = StringBuffer(
      'Se emitirá la factura para ${preview.cliente.nombre} '
      '(${formatPeriodo(_periodo)}) por '
      '${formatPesos(preview.totalRecibo)}.\n\n',
    );
    if (preview.cantidadRefacturadas > 0) {
      mensaje.write(
        '${preview.cantidadRefacturadas} '
        '${pluralES(preview.cantidadRefacturadas, "factura anterior será absorbida", "facturas anteriores serán absorbidas")} '
        '(${formatPesos(preview.totalRefacturado)} de saldo refacturado).\n\n',
      );
    }
    mensaje.write(
      'Si necesitas corregir algo después, puedes anular y los saldos '
      'refacturados volverán a estar pendientes.',
    );

    final ok = await confirm(
      context,
      titulo: 'Confirmar emisión',
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
      await service.ejecutarFacturaIndividual(
        preview: preview,
        periodo: _periodo,
        fechaEmision: _fechaEmision,
      );
      ref.invalidate(facturasListProvider);
      ref.invalidate(periodosExistentesProvider);
      ref.invalidate(cargosPendientesPorClienteProvider(widget.clienteId));
      if (!mounted) return;
      AppSnackbar.success(context, 'Factura emitida');
      context.go('/facturas?cliente=${widget.clienteId}');
    } catch (e, stack) {
      appLogger.e('Error emitiendo individual', error: e, stackTrace: stack);
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
      await _calcularPreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncCliente = ref.watch(clienteDetailProvider(widget.clienteId));

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
                onPressed: () =>
                    context.go('/clientes/${widget.clienteId}/editar'),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: AsyncValueWidget<Cliente>(
                  value: asyncCliente,
                  data: (cliente) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generar factura individual',
                        style: theme.textTheme.headlineMedium,
                      ),
                      Text(
                        'Cliente: ${cliente.nombre} · Código ${cliente.codigo}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapXl,
          _ParametrosCard(
            periodoLabel: formatPeriodo(_periodo),
            fechaEmision: _fechaEmision,
            calculando: _calculando,
            ejecutando: _ejecutando,
            onSeleccionarPeriodo: _seleccionarPeriodo,
            onRecalcular: _calcularPreview,
          ),
          if (_error != null) ...[
            AppSpacing.gapMd,
            ErrorBox.message(message: _error!),
          ],
          AppSpacing.gapLg,
          Expanded(
            child: SingleChildScrollView(
              child: _PreviewIndividual(
                preview: _preview,
                calculando: _calculando,
              ),
            ),
          ),
          if (_preview != null && _preview!.tieneCargos) ...[
            AppSpacing.gapLg,
            _AccionesEmitir(
              total: _preview!.totalRecibo,
              ejecutando: _ejecutando,
              onEjecutar: _ejecutar,
            ),
          ],
        ],
      ),
    );
  }
}

class _ParametrosCard extends StatelessWidget {
  const _ParametrosCard({
    required this.periodoLabel,
    required this.fechaEmision,
    required this.calculando,
    required this.ejecutando,
    required this.onSeleccionarPeriodo,
    required this.onRecalcular,
  });

  final String periodoLabel;
  final DateTime fechaEmision;
  final bool calculando;
  final bool ejecutando;
  final VoidCallback onSeleccionarPeriodo;
  final VoidCallback onRecalcular;

  @override
  Widget build(BuildContext context) {
    final disabled = calculando || ejecutando;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tight = constraints.maxWidth < 720;
            final periodo = _SelectorBox(
              icon: Icons.calendar_today,
              label: 'Periodo',
              value: periodoLabel,
              onTap: disabled ? null : onSeleccionarPeriodo,
            );
            final fecha = _SelectorBox(
              icon: Icons.event,
              label: 'Fecha de emisión',
              value: formatFecha(fechaEmision),
            );
            final boton = OutlinedButton.icon(
              onPressed: disabled ? null : onRecalcular,
              icon: calculando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(calculando ? 'Calculando...' : 'Recalcular'),
            );
            if (tight) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  periodo,
                  AppSpacing.gapMd,
                  fecha,
                  AppSpacing.gapMd,
                  boton,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: periodo),
                AppSpacing.gapMd,
                Expanded(child: fecha),
                AppSpacing.gapLg,
                boton,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SelectorBox extends StatelessWidget {
  const _SelectorBox({
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
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            borderRadius: BorderRadius.circular(8),
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
              if (onTap != null)
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

class _PreviewIndividual extends StatelessWidget {
  const _PreviewIndividual({required this.preview, required this.calculando});

  final PreviewFacturaCliente? preview;
  final bool calculando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (calculando && preview == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (preview == null) {
      return const SizedBox.shrink();
    }
    final p = preview!;
    if (!p.tieneCargos) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                AppSpacing.gapMd,
                Text(
                  'Sin cargos para emitir',
                  style: theme.textTheme.titleMedium,
                ),
                AppSpacing.gapXs,
                Text(
                  'Este cliente no tiene mensualidad, mora ni cargos extras '
                  'pendientes para el periodo seleccionado.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final lineas = <_LineaResumen>[];
    if (p.valorMensualidad > 0) {
      lineas.add(
        _LineaResumen(
          icon: Icons.event_repeat,
          titulo: 'Mensualidad',
          valor: p.valorMensualidad,
        ),
      );
    }
    if (p.valorMora > 0) {
      lineas.add(
        _LineaResumen(
          icon: Icons.warning_amber,
          titulo: 'Intereses de mora',
          valor: p.valorMora,
          subtitulo: p.cantidadRefacturadas > 0
              ? 'Acumulada sobre saldos refacturados'
              : null,
        ),
      );
    }
    if (p.costoReconexion > 0) {
      lineas.add(
        _LineaResumen(
          icon: Icons.power_settings_new,
          titulo: 'Costo de reconexión',
          valor: p.costoReconexion,
        ),
      );
    }
    for (final c in p.cargosExtras) {
      lineas.add(
        _LineaResumen(
          icon: Icons.label_outline,
          titulo: c.descripcion,
          subtitulo: c.cantidad > 1
              ? '${c.cantidad} × ${formatPesos(c.valorUnitario)}'
              : null,
          valor: c.subtotal,
        ),
      );
    }
    for (final r in p.lineasRefacturadas) {
      lineas.add(
        _LineaResumen(
          icon: Icons.history,
          titulo: 'Saldo pendiente ${r.numero}',
          subtitulo: 'Periodo ${formatPeriodo(r.periodo)} · refacturado',
          valor: r.saldo,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Conceptos a facturar', style: theme.textTheme.titleMedium),
            AppSpacing.gapMd,
            for (final l in lineas) ...[
              _LineaWidget(linea: l),
              Divider(
                height: AppSpacing.lg,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ],
            Row(
              children: [
                Text('Total a cobrar', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  formatPesos(p.totalRecibo),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (p.cantidadRefacturadas > 0) ...[
              AppSpacing.gapSm,
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.merge_type,
                      size: 18,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    AppSpacing.gapSm,
                    Expanded(
                      child: Text(
                        'Al emitir, '
                        '${pluralES(p.cantidadRefacturadas, "factura anterior pasará a estado refacturada", "facturas anteriores pasarán a estado refacturada")} '
                        'y su saldo (${formatPesos(p.totalRefacturado)}) se cobrará en esta nueva factura.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineaResumen {
  const _LineaResumen({
    required this.icon,
    required this.titulo,
    required this.valor,
    this.subtitulo,
  });
  final IconData icon;
  final String titulo;
  final String? subtitulo;
  final int valor;
}

class _LineaWidget extends StatelessWidget {
  const _LineaWidget({required this.linea});
  final _LineaResumen linea;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(linea.icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        AppSpacing.gapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                linea.titulo,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (linea.subtitulo != null)
                Text(
                  linea.subtitulo!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Text(
          formatPesos(linea.valor),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _AccionesEmitir extends StatelessWidget {
  const _AccionesEmitir({
    required this.total,
    required this.ejecutando,
    required this.onEjecutar,
  });

  final int total;
  final bool ejecutando;
  final VoidCallback onEjecutar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total a emitir',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatPesos(total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: ejecutando ? null : onEjecutar,
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
