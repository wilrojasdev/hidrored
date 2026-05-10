import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/formato.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_async_value.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/evento_servicio.dart';
import '../../../../domain/enums.dart';
import '../../../facturacion/presentation/facturas_controller.dart';
import '../servicio_controllers.dart';

class BitacoraTab extends ConsumerWidget {
  const BitacoraTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEventos = ref.watch(eventosRecientesProvider);
    final asyncClientes = ref.watch(clientesMapProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AsyncValueWidget<Map<String, Cliente>>(
        value: asyncClientes,
        loading: ListView.separated(
          itemCount: 5,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, _) => const ListTileSkeleton(),
        ),
        data: (clientesMap) => AsyncValueWidget<List<EventoServicio>>(
          value: asyncEventos,
          onRetry: () => ref.invalidate(eventosRecientesProvider),
          loading: ListView.separated(
            itemCount: 5,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, _) => const ListTileSkeleton(),
          ),
          data: (eventos) {
            if (eventos.isEmpty) {
              return const AppEmptyState(
                icon: Icons.history,
                titulo: 'Sin eventos aún',
                descripcion:
                    'A medida que cambies estados, suspendas o reactives '
                    'clientes, aquí verás el historial.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(eventosRecientesProvider);
                await ref.read(eventosRecientesProvider.future);
              },
              child: ListView.separated(
                itemCount: eventos.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final ev = eventos[i];
                  return _EventoTile(
                    evento: ev,
                    cliente: clientesMap[ev.clienteId],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EventoTile extends StatelessWidget {
  const _EventoTile({required this.evento, required this.cliente});
  final EventoServicio evento;
  final Cliente? cliente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icono, color) = _iconoYColor(evento.tipo);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icono, color: color),
      ),
      title: Row(
        children: [
          Text(
            _tipoLabel(evento.tipo),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cliente?.nombre ?? 'Cliente',
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${DateFormat('dd/MM/yyyy HH:mm').format(evento.fecha)}'
        '${evento.motivo == null ? '' : ' · ${evento.motivo}'}',
      ),
      trailing: evento.costo != null && evento.costo! > 0
          ? Text(
              formatPesos(evento.costo!),
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          : null,
      onTap: cliente == null
          ? null
          : () => context.go('/servicio/bitacora/${cliente!.id}'),
    );
  }

  (IconData, Color) _iconoYColor(TipoEventoServicio tipo) => switch (tipo) {
    TipoEventoServicio.activacion => (Icons.check_circle_outline, Colors.green),
    TipoEventoServicio.suspension => (Icons.block, Colors.red),
    TipoEventoServicio.reconexion => (Icons.power, Colors.green),
    TipoEventoServicio.reporteDano => (
      Icons.report_problem_outlined,
      Colors.amber,
    ),
    TipoEventoServicio.inicioReparacion => (Icons.build, Colors.blue),
    TipoEventoServicio.finReparacion => (Icons.task_alt, Colors.green),
    TipoEventoServicio.retiro => (Icons.person_off_outlined, Colors.grey),
    TipoEventoServicio.cambioEstado => (Icons.swap_horiz, Colors.deepPurple),
  };

  String _tipoLabel(TipoEventoServicio tipo) => switch (tipo) {
    TipoEventoServicio.activacion => 'Activación',
    TipoEventoServicio.suspension => 'Suspensión',
    TipoEventoServicio.reconexion => 'Reconexión',
    TipoEventoServicio.reporteDano => 'Reporte de daño',
    TipoEventoServicio.inicioReparacion => 'Inicio reparación',
    TipoEventoServicio.finReparacion => 'Fin reparación',
    TipoEventoServicio.retiro => 'Retiro',
    TipoEventoServicio.cambioEstado => 'Cambio de estado',
  };
}
