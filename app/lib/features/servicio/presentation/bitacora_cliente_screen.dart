import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/status_mappers.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/evento_servicio.dart';
import '../../../domain/enums.dart';
import '../../clientes/presentation/clientes_controller.dart';
import 'servicio_controllers.dart';

class BitacoraClienteScreen extends ConsumerWidget {
  const BitacoraClienteScreen({super.key, required this.clienteId});
  final String clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncCliente = ref.watch(clienteDetailProvider(clienteId));
    final asyncEventos = ref.watch(bitacoraClienteProvider(clienteId));

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
                  'Bitácora del cliente',
                  style: theme.textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          AsyncValueWidget<Cliente>(
            value: asyncCliente,
            data: (s) => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '${s.codigo}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${formatCedula(s.cedula)}${s.direccion == null ? '' : ' · ${s.direccion}'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: s.estado.label,
                      variant: s.estado.variant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.gapLg,
          Expanded(
            child: AsyncValueWidget<List<EventoServicio>>(
              value: asyncEventos,
              onRetry: () => ref.invalidate(bitacoraClienteProvider(clienteId)),
              data: (eventos) {
                if (eventos.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.history,
                    titulo: 'Sin eventos',
                    descripcion:
                        'Este cliente todavía no tiene cambios registrados '
                        'en su historial de servicio.',
                  );
                }
                return ListView.separated(
                  itemCount: eventos.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _EventoTile(evento: eventos[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventoTile extends StatelessWidget {
  const _EventoTile({required this.evento});
  final EventoServicio evento;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(Icons.event_note_outlined),
      title: Text(_tipoLabel(evento.tipo)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(evento.fecha),
            style: theme.textTheme.bodySmall,
          ),
          if (evento.motivo != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(evento.motivo!),
            ),
        ],
      ),
      trailing: evento.costo != null && evento.costo! > 0
          ? Text(formatPesos(evento.costo!))
          : null,
    );
  }

  String _tipoLabel(TipoEventoServicio tipo) => switch (tipo) {
    TipoEventoServicio.activacion => 'Activación',
    TipoEventoServicio.suspension => 'Suspensión',
    TipoEventoServicio.reconexion => 'Reconexión',
    TipoEventoServicio.reporteDano => 'Reporte de daño',
    TipoEventoServicio.inicioReparacion => 'Inicio de reparación',
    TipoEventoServicio.finReparacion => 'Fin de reparación',
    TipoEventoServicio.retiro => 'Retiro',
    TipoEventoServicio.cambioEstado => 'Cambio de estado',
  };
}
