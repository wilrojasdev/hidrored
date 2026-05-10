import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/pago.dart';
import '../../facturacion/presentation/facturas_controller.dart';
import 'pagos_controller.dart';

class PagosListScreen extends ConsumerWidget {
  const PagosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncList = ref.watch(pagosListProvider);
    final asyncClientes = ref.watch(clientesMapProvider);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppSizes.mobileBreakpoint;

    return Padding(
      padding: isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pagos', style: theme.textTheme.headlineSmall),
                AppSpacing.gapSm,
                FilledButton.icon(
                  onPressed: () => context.go('/pagos/nuevo'),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar pago'),
                ),
              ],
            )
          else
            Row(
              children: [
                Text('Pagos', style: theme.textTheme.headlineMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/pagos/nuevo'),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar pago'),
                ),
              ],
            ),
          AppSpacing.gapXs,
          Text(
            'Pagos recibidos por Bancolombia, Nequi o efectivo. Cuando '
            'registras uno, automáticamente se aplica primero a las facturas '
            'más antiguas del cliente.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapLg,
          Expanded(
            child: AsyncValueWidget<Map<String, Cliente>>(
              value: asyncClientes,
              loading: const _PagosSkeleton(),
              data: (clientesMap) => AsyncValueWidget<List<Pago>>(
                value: asyncList,
                onRetry: () => ref.invalidate(pagosListProvider),
                loading: const _PagosSkeleton(),
                data: (lista) {
                  if (lista.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.payments_outlined,
                      titulo: 'Sin pagos aún',
                      descripcion:
                          'Cuando un cliente te pague, registra el pago aquí. '
                          'La app aplicará el dinero a sus facturas pendientes.',
                      acciones: [
                        FilledButton.icon(
                          onPressed: () => context.go('/pagos/nuevo'),
                          icon: const Icon(Icons.add),
                          label: const Text('Registrar primer pago'),
                        ),
                      ],
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(pagosListProvider);
                      await ref.read(pagosListProvider.future);
                    },
                    child: ListView.separated(
                      itemCount: lista.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => _PagoTile(
                        pago: lista[i],
                        cliente: clientesMap[lista[i].clienteId],
                      ),
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

class _PagosSkeleton extends StatelessWidget {
  const _PagosSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => const ListTileSkeleton(),
    );
  }
}

class _PagoTile extends StatelessWidget {
  const _PagoTile({required this.pago, required this.cliente});
  final Pago pago;
  final Cliente? cliente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nombreCliente = cliente?.nombre ?? 'Cliente';
    return Semantics(
      button: true,
      label:
          'Pago de $nombreCliente, ${formatPesos(pago.valor)}, '
          '${pago.metodo.label}, ${formatFecha(pago.fecha)}',
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.tertiaryContainer,
          child: Icon(
            Icons.payments,
            color: theme.colorScheme.onTertiaryContainer,
            semanticLabel: 'Pago',
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                nombreCliente,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppSpacing.gapSm,
            _MetodoChip(metodo: pago.metodo.label),
          ],
        ),
        subtitle: Text(
          '${formatFecha(pago.fecha)}'
          '${pago.referencia == null ? '' : ' · Ref: ${pago.referencia}'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatPesos(pago.valor),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            AppSpacing.gapSm,
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.go('/pagos/${pago.id}'),
      ),
    );
  }
}

class _MetodoChip extends StatelessWidget {
  const _MetodoChip({required this.metodo});
  final String metodo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        metodo,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
