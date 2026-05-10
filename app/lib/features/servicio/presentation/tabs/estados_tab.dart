import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/formato.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_async_value.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fields.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/status_mappers.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/enums.dart';
import '../../../clientes/presentation/clientes_controller.dart';
import '../../data/servicio_repository.dart';

class EstadosTab extends ConsumerStatefulWidget {
  const EstadosTab({super.key});

  @override
  ConsumerState<EstadosTab> createState() => _EstadosTabState();
}

class _EstadosTabState extends ConsumerState<EstadosTab> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  EstadoCliente? _filtroEstado;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(AppDurations.searchDebounce, () {
      ref.read(clientesSearchProvider.notifier).state = v;
    });
  }

  Future<void> _cambiarEstado(Cliente s) async {
    final result = await showDialog<_CambioEstadoResult>(
      context: context,
      builder: (ctx) => _CambioEstadoDialog(cliente: s),
    );
    if (result == null) return;
    try {
      await ref
          .read(servicioRepositoryProvider)
          .cambiarEstado(
            clienteId: s.id,
            nuevoEstado: result.nuevoEstado,
            tipoEvento: result.tipoEvento,
            motivo: result.motivo,
            costo: result.costo,
          );
      ref.invalidate(clientesListProvider);
      if (!mounted) return;
      AppSnackbar.success(
        context,
        'Estado cambiado a ${result.nuevoEstado.label}',
      );
    } catch (e, stack) {
      appLogger.e('Error al cambiar estado', error: e, stackTrace: stack);
      if (!mounted) return;
      AppSnackbar.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(clientesListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre, cédula o dirección',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              DropdownMenu<EstadoCliente?>(
                initialSelection: _filtroEstado,
                label: const Text('Estado'),
                width: 220,
                onSelected: (v) => setState(() => _filtroEstado = v),
                dropdownMenuEntries: [
                  const DropdownMenuEntry(value: null, label: 'Todos'),
                  for (final e in EstadoCliente.values)
                    DropdownMenuEntry(value: e, label: e.label),
                ],
              ),
            ],
          ),
          AppSpacing.gapMd,
          Expanded(
            child: AsyncValueWidget<List<Cliente>>(
              value: asyncList,
              onRetry: () => ref.invalidate(clientesListProvider),
              loading: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, _) => const ListTileSkeleton(),
              ),
              data: (lista) {
                final filtrada = _filtroEstado == null
                    ? lista
                    : lista.where((s) => s.estado == _filtroEstado).toList();
                if (filtrada.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.search_off,
                    titulo: 'Sin resultados',
                    descripcion:
                        'Prueba a quitar el filtro de estado o cambiar la búsqueda.',
                  );
                }
                return ListView.separated(
                  itemCount: filtrada.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _ClienteEstadoTile(
                    cliente: filtrada[i],
                    onCambiarEstado: () => _cambiarEstado(filtrada[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClienteEstadoTile extends StatelessWidget {
  const _ClienteEstadoTile({
    required this.cliente,
    required this.onCambiarEstado,
  });
  final Cliente cliente;
  final VoidCallback onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          '${cliente.codigo}',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        cliente.nombre,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${formatCedula(cliente.cedula)}${cliente.direccion == null ? '' : ' · ${cliente.direccion}'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusChip(
            label: cliente.estado.label,
            variant: cliente.estado.variant,
            compact: true,
          ),
          AppSpacing.gapSm,
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Cambiar estado',
            onPressed: onCambiarEstado,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Bitácora',
            onPressed: () => context.go('/servicio/bitacora/${cliente.id}'),
          ),
        ],
      ),
      onTap: () => context.go('/clientes/${cliente.id}/editar'),
    );
  }
}

// ---------- Dialogo cambio de estado ----------

class _CambioEstadoResult {
  _CambioEstadoResult({
    required this.nuevoEstado,
    required this.tipoEvento,
    this.motivo,
    this.costo,
  });
  final EstadoCliente nuevoEstado;
  final TipoEventoServicio tipoEvento;
  final String? motivo;
  final int? costo;
}

class _CambioEstadoDialog extends StatefulWidget {
  const _CambioEstadoDialog({required this.cliente});
  final Cliente cliente;

  @override
  State<_CambioEstadoDialog> createState() => _CambioEstadoDialogState();
}

class _CambioEstadoDialogState extends State<_CambioEstadoDialog> {
  late EstadoCliente _nuevoEstado;
  final _motivoCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nuevoEstado = widget.cliente.estado;
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _costoCtrl.dispose();
    super.dispose();
  }

  TipoEventoServicio _tipoFromEstado(
    EstadoCliente anterior,
    EstadoCliente nuevo,
  ) {
    if (nuevo == EstadoCliente.suspendidoMora ||
        nuevo == EstadoCliente.suspendidoVoluntario) {
      return TipoEventoServicio.suspension;
    }
    if (anterior != EstadoCliente.activo && nuevo == EstadoCliente.activo) {
      return TipoEventoServicio.reconexion;
    }
    if (nuevo == EstadoCliente.danoReportado) {
      return TipoEventoServicio.reporteDano;
    }
    if (nuevo == EstadoCliente.enReparacion) {
      return TipoEventoServicio.inicioReparacion;
    }
    if (nuevo == EstadoCliente.retirado) return TipoEventoServicio.retiro;
    return TipoEventoServicio.cambioEstado;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cambiar estado: ${widget.cliente.nombre}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<EstadoCliente>(
              initialValue: _nuevoEstado,
              decoration: const InputDecoration(labelText: 'Nuevo estado'),
              onChanged: (v) {
                if (v != null) setState(() => _nuevoEstado = v);
              },
              items: [
                for (final e in EstadoCliente.values)
                  DropdownMenuItem(value: e, child: Text(e.label)),
              ],
            ),
            AppSpacing.gapMd,
            TextField(
              controller: _motivoCtrl,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Por qué se cambia el estado',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            if (_nuevoEstado == EstadoCliente.activo &&
                widget.cliente.estado != EstadoCliente.activo) ...[
              AppSpacing.gapMd,
              MoneyField(
                controller: _costoCtrl,
                label: 'Costo de reconexión (opcional)',
                helperText: 'Se sumará a la próxima factura',
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final tipo = _tipoFromEstado(widget.cliente.estado, _nuevoEstado);
            final costo = parsePesos(_costoCtrl.text);
            Navigator.pop(
              context,
              _CambioEstadoResult(
                nuevoEstado: _nuevoEstado,
                tipoEvento: tipo,
                motivo: _motivoCtrl.text.trim().isEmpty
                    ? null
                    : _motivoCtrl.text.trim(),
                costo: costo,
              ),
            );
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
