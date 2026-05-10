import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/formato.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_async_value.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/status_mappers.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/dano.dart';
import '../../../facturacion/presentation/facturas_controller.dart';
import '../servicio_controllers.dart';

class DanosTab extends ConsumerWidget {
  const DanosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncList = ref.watch(danosListProvider);
    final asyncClientes = ref.watch(clientesMapProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Daños registrados',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/servicio/danos/nuevo'),
                icon: const Icon(Icons.add),
                label: const Text('Reportar daño'),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Expanded(
            child: AsyncValueWidget<Map<String, Cliente>>(
              value: asyncClientes,
              loading: ListView.separated(
                itemCount: 4,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, _) => const ListTileSkeleton(),
              ),
              data: (clientesMap) => AsyncValueWidget<List<Dano>>(
                value: asyncList,
                onRetry: () => ref.invalidate(danosListProvider),
                loading: ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, _) => const ListTileSkeleton(),
                ),
                data: (lista) {
                  if (lista.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.build_circle_outlined,
                      titulo: 'Sin daños reportados',
                      descripcion:
                          'Cuando un cliente reporte una avería en su servicio, '
                          'regístrala aquí para hacerle seguimiento.',
                      acciones: [
                        FilledButton.icon(
                          onPressed: () => context.go('/servicio/danos/nuevo'),
                          icon: const Icon(Icons.add),
                          label: const Text('Reportar daño'),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _DanoTile(
                      dano: lista[i],
                      cliente: clientesMap[lista[i].clienteId],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DanoTile extends StatelessWidget {
  const _DanoTile({required this.dano, required this.cliente});
  final Dano dano;
  final Cliente? cliente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.build_circle_outlined,
        color: theme.colorScheme.primary,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              cliente?.nombre ?? 'Cliente',
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.gapSm,
          StatusChip(
            label: dano.estado.label,
            variant: dano.estado.variant,
            compact: true,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dano.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            'Reportado ${formatFecha(dano.fechaReporte)}'
            '${dano.fechaSolucion != null ? ' · Solucionado ${formatFecha(dano.fechaSolucion!)}' : ''}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dano.costo > 0) ...[
            Text(
              formatPesos(dano.costo),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            AppSpacing.gapSm,
          ],
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => context.go('/servicio/danos/${dano.id}/editar'),
    );
  }
}
