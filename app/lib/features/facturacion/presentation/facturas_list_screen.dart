import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/status_mappers.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/enums.dart';
import '../../recibos/presentation/recibo_actions.dart';
import 'facturas_controller.dart';

/// Fecha de vencimiento (solo día) común a toda la lista, o null si hay más de una.
DateTime? _fechaVencimientoComun(List<Factura> facturas) {
  if (facturas.isEmpty) return null;
  final first = facturas.first.fechaVencimiento;
  final y0 = first.year, m0 = first.month, d0 = first.day;
  for (final f in facturas.skip(1)) {
    final v = f.fechaVencimiento;
    if (v.year != y0 || v.month != m0 || v.day != d0) return null;
  }
  return DateTime(y0, m0, d0);
}

class FacturasListScreen extends ConsumerStatefulWidget {
  const FacturasListScreen({super.key});

  @override
  ConsumerState<FacturasListScreen> createState() => _FacturasListScreenState();
}

class _FacturasListScreenState extends ConsumerState<FacturasListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(AppDurations.searchDebounce, () {
      setState(() => _query = v.trim().toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncList = ref.watch(facturasListProvider);
    final asyncClientes = ref.watch(clientesMapProvider);
    final filtro = ref.watch(facturasFiltroProvider);
    final asyncPeriodos = ref.watch(periodosExistentesProvider);
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
                Text('Facturación', style: theme.textTheme.headlineSmall),
                AppSpacing.gapSm,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _LoteRecibosButtons(asyncList: asyncList),
                    FilledButton.icon(
                      onPressed: () => context.go('/facturas/generar'),
                      icon: const Icon(Icons.playlist_add_check),
                      label: const Text('Generar mes'),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Text('Facturación', style: theme.textTheme.headlineMedium),
                const Spacer(),
                _LoteRecibosButtons(asyncList: asyncList),
                AppSpacing.gapMd,
                FilledButton.icon(
                  onPressed: () => context.go('/facturas/generar'),
                  icon: const Icon(Icons.playlist_add_check),
                  label: const Text('Generar mes'),
                ),
              ],
            ),
          AppSpacing.gapLg,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar por número o cliente',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearchChanged('');
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              asyncPeriodos.when(
                data: (periodos) => DropdownMenu<String?>(
                  initialSelection: filtro.periodo,
                  label: const Text('Periodo'),
                  width: 200,
                  onSelected: (v) {
                    ref.read(facturasFiltroProvider.notifier).state = filtro
                        .copyWith(periodo: v);
                  },
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: null, label: 'Todos'),
                    for (final p in periodos)
                      DropdownMenuEntry(value: p, label: formatPeriodo(p)),
                  ],
                ),
                loading: () => const SizedBox(width: 200),
                error: (_, _) => const SizedBox.shrink(),
              ),
              DropdownMenu<EstadoFactura?>(
                initialSelection: filtro.estado,
                label: const Text('Estado'),
                width: 200,
                onSelected: (v) {
                  ref.read(facturasFiltroProvider.notifier).state = filtro
                      .copyWith(estado: v);
                },
                dropdownMenuEntries: [
                  const DropdownMenuEntry(value: null, label: 'Todos'),
                  for (final e in EstadoFactura.values)
                    DropdownMenuEntry(value: e, label: e.label),
                ],
              ),
              if (filtro.periodo != null ||
                  filtro.estado != null ||
                  _query.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                  onPressed: () {
                    ref.read(facturasFiltroProvider.notifier).state =
                        const FacturasFiltro();
                    _searchCtrl.clear();
                    _onSearchChanged('');
                    setState(() {});
                  },
                ),
            ],
          ),
          AppSpacing.gapLg,
          Expanded(
            child: AsyncValueWidget<Map<String, Cliente>>(
              value: asyncClientes,
              loading: const _FacturasSkeleton(),
              data: (clientesMap) => AsyncValueWidget<List<Factura>>(
                value: asyncList,
                onRetry: () => ref.invalidate(facturasListProvider),
                loading: const _FacturasSkeleton(),
                data: (lista) {
                  final filtrada = _query.isEmpty
                      ? lista
                      : lista.where((f) {
                          final cliente = clientesMap[f.clienteId];
                          return f.numero.toLowerCase().contains(_query) ||
                              (cliente?.nombre.toLowerCase().contains(_query) ??
                                  false) ||
                              (cliente?.cedula.contains(_query) ?? false);
                        }).toList();

                  if (filtrada.isEmpty) {
                    if (lista.isNotEmpty) {
                      return const AppEmptyState(
                        icon: Icons.search_off,
                        titulo: 'Sin resultados',
                        descripcion:
                            'No encontramos facturas que coincidan con los filtros.',
                      );
                    }
                    return AppEmptyState(
                      icon: Icons.receipt_long_outlined,
                      titulo: 'Sin facturas aún',
                      descripcion:
                          'Genera la facturación del mes para emitir las facturas '
                          'a tus clientes activos.',
                      acciones: [
                        FilledButton.icon(
                          onPressed: () => context.go('/facturas/generar'),
                          icon: const Icon(Icons.playlist_add_check),
                          label: const Text('Generar mes'),
                        ),
                      ],
                    );
                  }
                  final vencimientoComun = _fechaVencimientoComun(filtrada);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (vencimientoComun != null) ...[
                        _VencimientoComunBanner(fecha: vencimientoComun),
                        AppSpacing.gapSm,
                      ],
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(facturasListProvider);
                            await ref.read(facturasListProvider.future);
                          },
                          child: ListView.separated(
                            itemCount: filtrada.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) => _FacturaTile(
                              factura: filtrada[i],
                              cliente: clientesMap[filtrada[i].clienteId],
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _LoteRecibosButtons extends ConsumerWidget {
  const _LoteRecibosButtons({required this.asyncList});
  final AsyncValue<List<Factura>> asyncList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncList.when(
      data: (lista) {
        final imprimibles = lista
            .where((f) => f.estado != EstadoFactura.anulada)
            .toList();
        final n = imprimibles.length;
        final vacio = imprimibles.isEmpty;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: vacio
                  ? null
                  : () => ReciboActions.imprimirLote(context, ref, imprimibles),
              icon: const Icon(Icons.print_outlined),
              label: Text('Imprimir lote ($n)'),
            ),
            OutlinedButton.icon(
              onPressed: vacio
                  ? null
                  : () => ReciboActions.compartirLote(context, ref, imprimibles),
              icon: const Icon(Icons.share_outlined),
              label: Text('Compartir PDF ($n)'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _VencimientoComunBanner extends StatelessWidget {
  const _VencimientoComunBanner({required this.fecha});

  final DateTime fecha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            AppSpacing.gapSm,
            Expanded(
              child: Text(
                'Vencimiento: ${formatFecha(fecha)}',
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
}

class _FacturasSkeleton extends StatelessWidget {
  const _FacturasSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => const ListTileSkeleton(),
    );
  }
}

class _FacturaTile extends StatelessWidget {
  const _FacturaTile({required this.factura, required this.cliente});

  final Factura factura;
  final Cliente? cliente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nombreCliente = cliente?.nombre ?? 'Cliente';
    return Semantics(
      button: true,
      label:
          'Factura ${factura.numero}, $nombreCliente, '
          'estado ${factura.estado.label}, ${formatPesos(factura.total)}',
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                nombreCliente,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            AppSpacing.gapSm,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip(
                  label: factura.estado.label,
                  variant: factura.estado.variant,
                  compact: true,
                ),
                if (factura.tipo == TipoFactura.recordatorioSuspension) ...[
                  AppSpacing.gapXs,
                  const StatusChip(
                    label: 'Suspendido',
                    variant: StatusVariant.warning,
                    compact: true,
                    icon: Icons.block,
                  ),
                ],
              ],
            ),
          ],
        ),
        subtitle: Text(
          '${factura.numero} · ${formatPeriodo(factura.periodo)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatPesos(factura.total),
              style: AppListTypography.monto(
                theme,
                color: factura.estado == EstadoFactura.anulada
                    ? theme.colorScheme.outline
                    : null,
              ),
            ),
            AppSpacing.gapSm,
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.go('/facturas/${factura.id}'),
      ),
    );
  }
}
