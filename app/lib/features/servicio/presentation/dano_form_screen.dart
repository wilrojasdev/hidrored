import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/dano.dart';
import '../../../domain/enums.dart';
import '../../clientes/presentation/clientes_controller.dart';
import '../data/dano_repository.dart';
import '../data/servicio_repository.dart';
import 'servicio_controllers.dart';

class DanoFormScreen extends ConsumerWidget {
  const DanoFormScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = id != null;
    final theme = Theme.of(context);
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
                onPressed: () => context.go('/servicio'),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  isEdit ? 'Editar daño' : 'Reportar daño',
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
                child: isEdit ? _EditForm(id: id!) : const _DanoFormBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditForm extends ConsumerWidget {
  const _EditForm({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDano = ref.watch(danoDetailProvider(id));
    return AsyncValueWidget<Dano>(
      value: asyncDano,
      onRetry: () => ref.invalidate(danoDetailProvider(id)),
      data: (d) => _DanoFormBody(initial: d),
    );
  }
}

class _DanoFormBody extends ConsumerStatefulWidget {
  const _DanoFormBody({this.initial});
  final Dano? initial;

  @override
  ConsumerState<_DanoFormBody> createState() => _DanoFormBodyState();
}

class _DanoFormBodyState extends ConsumerState<_DanoFormBody> {
  final _formKey = GlobalKey<FormState>();
  Cliente? _cliente;
  late DateTime _fechaReporte;
  DateTime? _fechaSolucion;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _costoCtrl;
  late TextEditingController _reportadoPorCtrl;
  late TextEditingController _notasCtrl;
  late EstadoDano _estado;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _fechaReporte = d?.fechaReporte ?? DateTime.now();
    _fechaSolucion = d?.fechaSolucion;
    _descripcionCtrl = TextEditingController(text: d?.descripcion ?? '');
    _costoCtrl = TextEditingController(
      text: formatPesosNoSymbol(d?.costo ?? 0),
    );
    _reportadoPorCtrl = TextEditingController(text: d?.reportadoPor ?? '');
    _notasCtrl = TextEditingController(text: d?.notas ?? '');
    _estado = d?.estado ?? EstadoDano.reportado;
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _costoCtrl.dispose();
    _reportadoPorCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarCliente() async {
    final clientes = await ref.read(clientesListProvider.future);
    if (!mounted) return;
    final s = await showDialog<Cliente>(
      context: context,
      builder: (ctx) => _SelectorClienteDialog(clientes: clientes),
    );
    if (s != null) setState(() => _cliente = s);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _cliente == null) {
      AppSnackbar.errorMessage(context, 'Selecciona un cliente');
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(danoRepositoryProvider);
    final servicio = ref.read(servicioRepositoryProvider);
    try {
      final costoInt = parsePesos(_costoCtrl.text) ?? 0;
      if (_isEdit) {
        final estadoAnterior = widget.initial!.estado;
        await repo.update(
          widget.initial!.id,
          descripcion: _descripcionCtrl.text.trim(),
          costo: costoInt,
          reportadoPor: _reportadoPorCtrl.text.trim().isEmpty
              ? null
              : _reportadoPorCtrl.text.trim(),
          notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
          estado: _estado,
          fechaSolucion: _estado == EstadoDano.solucionado
              ? (_fechaSolucion ?? DateTime.now())
              : null,
        );

        if (_estado != estadoAnterior) {
          await _sincronizarEstadoCliente(
            clienteId: widget.initial!.clienteId,
            estadoAnterior: estadoAnterior,
            estadoNuevo: _estado,
            servicio: servicio,
          );
        }
      } else {
        final dano = await repo.create(
          clienteId: _cliente!.id,
          fechaReporte: _fechaReporte,
          descripcion: _descripcionCtrl.text.trim(),
          costo: costoInt,
          reportadoPor: _reportadoPorCtrl.text.trim().isEmpty
              ? null
              : _reportadoPorCtrl.text.trim(),
          notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
        );
        await servicio.cambiarEstado(
          clienteId: dano.clienteId,
          nuevoEstado: EstadoCliente.danoReportado,
          tipoEvento: TipoEventoServicio.reporteDano,
          motivo: _descripcionCtrl.text.trim(),
        );
      }
      ref.invalidate(danosListProvider);
      ref.invalidate(clientesListProvider);
      ref.invalidate(eventosRecientesProvider);
      if (!mounted) return;
      AppSnackbar.success(
        context,
        _isEdit ? 'Daño actualizado' : 'Daño reportado',
      );
      context.go('/servicio');
    } catch (e, stack) {
      appLogger.e('Error al guardar daño', error: e, stackTrace: stack);
      if (!mounted) return;
      AppSnackbar.error(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sincronizarEstadoCliente({
    required String clienteId,
    required EstadoDano estadoAnterior,
    required EstadoDano estadoNuevo,
    required dynamic servicio,
  }) async {
    if (estadoNuevo == EstadoDano.enReparacion &&
        estadoAnterior != EstadoDano.enReparacion) {
      await servicio.cambiarEstado(
        clienteId: clienteId,
        nuevoEstado: EstadoCliente.enReparacion,
        tipoEvento: TipoEventoServicio.inicioReparacion,
        motivo: 'Inicio de reparación',
      );
    } else if (estadoNuevo == EstadoDano.solucionado) {
      await servicio.cambiarEstado(
        clienteId: clienteId,
        nuevoEstado: EstadoCliente.activo,
        tipoEvento: TipoEventoServicio.finReparacion,
        motivo: 'Daño solucionado',
        costo: parsePesos(_costoCtrl.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isEdit)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_cliente == null)
                      FilledButton.tonalIcon(
                        onPressed: _saving ? null : _seleccionarCliente,
                        icon: const Icon(Icons.person_search),
                        label: const Text('Seleccionar cliente'),
                      )
                    else
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text('${_cliente!.codigo}'),
                        ),
                        title: Text(_cliente!.nombre),
                        subtitle: Text(
                          '${formatCedula(_cliente!.cedula)}${_cliente!.direccion == null ? '' : ' · ${_cliente!.direccion}'}',
                        ),
                        trailing: TextButton(
                          onPressed: _saving ? null : _seleccionarCliente,
                          child: const Text('Cambiar'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (!_isEdit) const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha de reporte'),
                    subtitle: Text(formatFecha(_fechaReporte)),
                    onTap: _saving
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fechaReporte,
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                            );
                            if (picked != null) {
                              setState(() => _fechaReporte = picked);
                            }
                          },
                  ),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del daño *',
                    ),
                    enabled: !_saving,
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _reportadoPorCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Reportado por',
                            hintText: 'Quien lo notificó',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          enabled: !_saving,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      AppSpacing.gapMd,
                      Expanded(
                        child: MoneyField(
                          controller: _costoCtrl,
                          label: 'Costo de reparación',
                          enabled: !_saving,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notasCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                    ),
                    enabled: !_saving,
                    maxLines: 2,
                  ),
                  if (_isEdit) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EstadoDano>(
                      initialValue: _estado,
                      decoration: const InputDecoration(
                        labelText: 'Estado del daño',
                      ),
                      onChanged: _saving
                          ? null
                          : (v) {
                              if (v != null) setState(() => _estado = v);
                            },
                      items: [
                        for (final e in EstadoDano.values)
                          DropdownMenuItem(value: e, child: Text(e.label)),
                      ],
                    ),
                    if (_estado == EstadoDano.solucionado) ...[
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_available),
                        title: const Text('Fecha de solución'),
                        subtitle: Text(
                          _fechaSolucion == null
                              ? 'Sin definir (se usa la fecha actual al guardar)'
                              : formatFecha(_fechaSolucion!),
                        ),
                        onTap: _saving
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaSolucion ?? DateTime.now(),
                                  firstDate: _fechaReporte,
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 1),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() => _fechaSolucion = picked);
                                }
                              },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: _saving ? null : () => context.go('/servicio'),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _saving ? null : _guardar,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Guardando...' : 'Guardar'),
              ),
            ],
          ),
        ],
      ),
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
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Seleccionar cliente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final s = _filtered[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${s.codigo}')),
                      title: Text(s.nombre),
                      subtitle: Text(formatCedula(s.cedula)),
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
