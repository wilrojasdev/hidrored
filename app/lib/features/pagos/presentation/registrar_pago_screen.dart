import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/enums.dart';
import '../../clientes/presentation/clientes_controller.dart';
import '../../facturacion/presentation/facturas_controller.dart';
import '../data/pago_repository.dart';
import '../domain/aplicacion_pago.dart';
import 'pagos_controller.dart';

class RegistrarPagoScreen extends ConsumerStatefulWidget {
  const RegistrarPagoScreen({super.key, this.clienteId});

  /// Si viene desde un cliente especifico, se prefilla.
  final String? clienteId;

  @override
  ConsumerState<RegistrarPagoScreen> createState() =>
      _RegistrarPagoScreenState();
}

class _RegistrarPagoScreenState extends ConsumerState<RegistrarPagoScreen> {
  Cliente? _cliente;
  DateTime _fecha = BogotaClock.hoy();
  MetodoPago _metodo = MetodoPago.bancolombia;
  final _valorCtrl = TextEditingController();
  final _referenciaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _valorCtrl.dispose();
    _referenciaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _cliente != null ||
      _valorCtrl.text.isNotEmpty ||
      _referenciaCtrl.text.isNotEmpty ||
      _notasCtrl.text.isNotEmpty;

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Fecha del pago',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _seleccionarCliente() async {
    final clientes = await ref.read(clientesListProvider.future);
    if (!mounted) return;
    final s = await showDialog<Cliente>(
      context: context,
      builder: (ctx) => _SelectorClienteDialog(clientes: clientes),
    );
    if (s != null) {
      setState(() {
        _cliente = s;
        _valorCtrl.clear();
      });
    }
  }

  Future<void> _registrar(AplicacionPago aplicacion) async {
    final valor = parsePesos(_valorCtrl.text);
    if (valor == null || valor <= 0) {
      AppSnackbar.errorMessage(context, 'Ingresa un valor mayor a cero');
      return;
    }

    final cerradas = aplicacion.aplicaciones
        .where((a) => a.monto >= a.factura.total)
        .length;
    final mensaje = StringBuffer(
      'Se registrarán ${formatPesos(valor)} para ${_cliente!.nombre}.\n\n',
    );
    if (cerradas == 0) {
      mensaje.write('No se cerrará ninguna factura completa.');
    } else {
      mensaje.write(pluralES(cerradas, 'factura cerrada', 'facturas cerradas'));
      mensaje.write('.');
    }
    if (aplicacion.faltante > 0) {
      mensaje.write(
        '\n\nFalta ${formatPesos(aplicacion.faltante)} para cubrir el saldo total.',
      );
    }
    if (aplicacion.sobrante > 0) {
      mensaje.write(
        '\n\nSobran ${formatPesos(aplicacion.sobrante)} (no se aplican).',
      );
    }

    final ok = await confirm(
      context,
      titulo: 'Confirmar pago',
      mensaje: mensaje.toString(),
      confirmar: 'Registrar',
      icono: Icons.payments_outlined,
    );
    if (!ok) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(pagoRepositoryProvider)
          .registrarPago(
            clienteId: _cliente!.id,
            fecha: _fecha,
            valor: valor,
            metodo: _metodo,
            referencia: _referenciaCtrl.text.trim().isEmpty
                ? null
                : _referenciaCtrl.text.trim(),
            notas: _notasCtrl.text.trim().isEmpty
                ? null
                : _notasCtrl.text.trim(),
            aplicacion: aplicacion,
          );
      ref.invalidate(pagosListProvider);
      ref.invalidate(facturasListProvider);
      ref.invalidate(facturasPendientesProvider(_cliente!.id));
      if (!mounted) return;
      AppSnackbar.success(context, 'Pago registrado');
      context.go('/pagos');
    } catch (e, stack) {
      appLogger.e('Error al registrar pago', error: e, stackTrace: stack);
      if (!mounted) return;
      AppSnackbar.error(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_dirty || _saving) return true;
    return confirmDiscardChanges(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onWillPop() && context.mounted) {
          context.go('/pagos');
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Volver',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await _onWillPop() && context.mounted) {
                      context.go('/pagos');
                    }
                  },
                ),
                AppSpacing.gapSm,
                Expanded(
                  child: Text(
                    'Registrar pago',
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
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.formMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cliente',
                                style: theme.textTheme.titleMedium,
                              ),
                              AppSpacing.gapMd,
                              if (_cliente == null)
                                FilledButton.tonalIcon(
                                  onPressed: _saving
                                      ? null
                                      : _seleccionarCliente,
                                  icon: const Icon(Icons.person_search),
                                  label: const Text('Seleccionar cliente'),
                                )
                              else
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Text(
                                      '${_cliente!.codigo}',
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    _cliente!.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${formatCedula(_cliente!.cedula)}'
                                    '${_cliente!.direccion == null ? '' : ' · ${_cliente!.direccion}'}',
                                  ),
                                  trailing: TextButton(
                                    onPressed: _saving
                                        ? null
                                        : _seleccionarCliente,
                                    child: const Text('Cambiar'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_cliente != null) ...[
                        AppSpacing.gapLg,
                        _SaldoCard(
                          clienteId: _cliente!.id,
                          valorCtrl: _valorCtrl,
                          onPrefill: () => setState(() {}),
                        ),
                        AppSpacing.gapLg,
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Datos del pago',
                                  style: theme.textTheme.titleMedium,
                                ),
                                AppSpacing.gapLg,
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: _saving
                                            ? null
                                            : _seleccionarFecha,
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusSm,
                                        ),
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: 'Fecha',
                                            prefixIcon: Icon(
                                              Icons.calendar_today,
                                            ),
                                          ),
                                          child: Text(formatFecha(_fecha)),
                                        ),
                                      ),
                                    ),
                                    AppSpacing.gapLg,
                                    Expanded(
                                      child: DropdownButtonFormField<MetodoPago>(
                                        initialValue: _metodo,
                                        decoration: const InputDecoration(
                                          labelText: 'Método',
                                          prefixIcon: Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                          ),
                                        ),
                                        onChanged: _saving
                                            ? null
                                            : (v) =>
                                                  setState(() => _metodo = v!),
                                        items: [
                                          for (final m in MetodoPago.values)
                                            DropdownMenuItem(
                                              value: m,
                                              child: Text(m.label),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.gapMd,
                                MoneyField(
                                  controller: _valorCtrl,
                                  label: 'Valor recibido',
                                  required: true,
                                  allowZero: false,
                                  enabled: !_saving,
                                  onChanged: (_) => setState(() {}),
                                ),
                                AppSpacing.gapMd,
                                TextField(
                                  controller: _referenciaCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Referencia (opcional)',
                                    hintText:
                                        'Ej. comprobante Bancolombia 12345',
                                    prefixIcon: Icon(Icons.receipt_outlined),
                                  ),
                                  enabled: !_saving,
                                  onChanged: (_) => setState(() {}),
                                ),
                                AppSpacing.gapMd,
                                TextField(
                                  controller: _notasCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Notas (opcional)',
                                    prefixIcon: Icon(Icons.note_outlined),
                                  ),
                                  enabled: !_saving,
                                  maxLines: 2,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.gapLg,
                        _AplicacionPreview(
                          clienteId: _cliente!.id,
                          valorCtrl: _valorCtrl,
                          saving: _saving,
                          onConfirm: _registrar,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaldoCard extends ConsumerWidget {
  const _SaldoCard({
    required this.clienteId,
    required this.valorCtrl,
    required this.onPrefill,
  });
  final String clienteId;
  final TextEditingController valorCtrl;
  final VoidCallback onPrefill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncFacturas = ref.watch(facturasPendientesProvider(clienteId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AsyncValueWidget<List<Factura>>(
          value: asyncFacturas,
          data: (facturas) {
            final saldo = facturas.fold<int>(0, (s, f) => s + f.total);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Saldo pendiente', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      formatPesos(saldo),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: saldo > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                    AppSpacing.gapMd,
                    if (saldo > 0)
                      OutlinedButton(
                        onPressed: () {
                          valorCtrl.text = formatPesosNoSymbol(saldo);
                          onPrefill();
                        },
                        child: const Text('Usar saldo'),
                      ),
                  ],
                ),
                if (facturas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Este cliente no tiene facturas pendientes.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else ...[
                  AppSpacing.gapMd,
                  for (final f in facturas)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          AppSpacing.gapSm,
                          Expanded(
                            child: Text(
                              '${f.numero} · ${formatPeriodo(f.periodo)}',
                            ),
                          ),
                          Text(formatPesos(f.total)),
                        ],
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AplicacionPreview extends ConsumerWidget {
  const _AplicacionPreview({
    required this.clienteId,
    required this.valorCtrl,
    required this.saving,
    required this.onConfirm,
  });
  final String clienteId;
  final TextEditingController valorCtrl;
  final bool saving;
  final void Function(AplicacionPago) onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final valor = parsePesos(valorCtrl.text) ?? 0;
    if (valor <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Text(
                  'Ingresa un valor para ver cómo se aplicará el pago.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final asyncFacturas = ref.watch(facturasPendientesProvider(clienteId));
    return AsyncValueWidget<List<Factura>>(
      value: asyncFacturas,
      data: (facturas) {
        final aplicacion = AplicacionPagoCalculator.calcular(
          facturasPendientes: facturas,
          valorPago: valor,
        );
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Aplicación del pago',
                      style: theme.textTheme.titleMedium,
                    ),
                    AppSpacing.gapSm,
                    Tooltip(
                      message:
                          'El pago se aplica primero a las facturas más antiguas. '
                          'Cuando una factura queda totalmente cubierta, se cierra.',
                      child: Icon(
                        Icons.help_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapXs,
                Text(
                  'Se aplica primero a la factura más antigua.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapMd,
                if (aplicacion.aplicaciones.isEmpty)
                  Text(
                    'Sin facturas pendientes — el pago se registra pero no '
                    'se aplica a ninguna factura.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  for (final a in aplicacion.aplicaciones)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            a.monto >= a.factura.total
                                ? Icons.check_circle
                                : Icons.adjust,
                            size: 16,
                            color: a.monto >= a.factura.total
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary,
                          ),
                          AppSpacing.gapSm,
                          Expanded(
                            child: Text(
                              '${a.factura.numero} · ${formatPeriodo(a.factura.periodo)}',
                            ),
                          ),
                          Text('${formatPesos(a.monto)} '),
                          Text(
                            '/ ${formatPesos(a.factura.total)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                if (aplicacion.faltante > 0) ...[
                  AppSpacing.gapSm,
                  Text(
                    'Falta ${formatPesos(aplicacion.faltante)} para cubrir el saldo total.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                if (aplicacion.sobrante > 0) ...[
                  AppSpacing.gapSm,
                  Text(
                    'Sobran ${formatPesos(aplicacion.sobrante)} (no se aplican a ninguna factura).',
                    style: TextStyle(color: theme.colorScheme.tertiary),
                  ),
                ],
                AppSpacing.gapLg,
                Row(
                  children: [
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: saving ? null : () => onConfirm(aplicacion),
                      icon: saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(saving ? 'Guardando...' : 'Registrar pago'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectorClienteDialog extends StatefulWidget {
  const _SelectorClienteDialog({required this.clientes});
  final List<Cliente> clientes;

  @override
  State<_SelectorClienteDialog> createState() => _SelectorClienteDialogState();
}

class _SelectorClienteDialogState extends State<_SelectorClienteDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cliente> get _filtered {
    if (_query.trim().isEmpty) return widget.clientes;
    final q = _query.toLowerCase();
    return widget.clientes.where((s) {
      return s.nombre.toLowerCase().contains(q) ||
          s.cedula.toLowerCase().contains(q) ||
          (s.direccion ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Seleccionar cliente',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              AppSpacing.gapMd,
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre, cédula o dirección',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Sin coincidencias',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final s = _filtered[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${s.codigo}')),
                            title: Text(s.nombre),
                            subtitle: Text(
                              '${formatCedula(s.cedula)}'
                              '${s.direccion == null ? '' : ' · ${s.direccion}'}',
                            ),
                            onTap: () => Navigator.pop(context, s),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
