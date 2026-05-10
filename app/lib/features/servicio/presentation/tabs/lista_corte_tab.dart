import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/formato.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_async_value.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../clientes/presentation/clientes_controller.dart';
import '../../data/servicio_repository.dart';
import '../../domain/lista_corte_service.dart';

class ListaCorteTab extends ConsumerWidget {
  const ListaCorteTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncList = ref.watch(listaCorteProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  AppSpacing.gapMd,
                  const Expanded(
                    child: Text(
                      'Aquí aparecen los clientes activos con dos o más '
                      'facturas vencidas y más de 5 días hábiles desde el '
                      'vencimiento de la segunda. La app los sugiere — la '
                      'decisión final de cortar es tuya.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: AsyncValueWidget<List<CandidatoCorte>>(
              value: asyncList,
              onRetry: () => ref.invalidate(listaCorteProvider),
              data: (lista) {
                if (lista.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.celebration_outlined,
                    titulo: 'Sin candidatos a corte',
                    descripcion:
                        'Ningún cliente cumple los criterios de suspensión por mora '
                        'en este momento.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(listaCorteProvider);
                    await ref.read(listaCorteProvider.future);
                  },
                  child: ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) =>
                        _CandidatoTile(candidato: lista[i]),
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

class _CandidatoTile extends ConsumerWidget {
  const _CandidatoTile({required this.candidato});
  final CandidatoCorte candidato;

  Future<void> _suspender(BuildContext context, WidgetRef ref) async {
    final motivoCtrl = TextEditingController(
      text: 'Suspendido por mora — ${candidato.cantidadFacturasLabel}',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Suspender a ${candidato.cliente.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${candidato.mesesConsecutivosEnMora} meses consecutivos en mora.\n'
              'Total adeudado: ${formatPesos(candidato.totalAdeudado)}\n'
              'Más vencida: ${candidato.diasVencidoMasViejo} días.\n\n'
              'Recuerda cerrar físicamente la llave en campo.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivoCtrl,
              decoration: const InputDecoration(labelText: 'Motivo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Suspender'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(servicioRepositoryProvider)
          .suspenderPorMora(
            candidato.cliente.id,
            motivo: motivoCtrl.text.trim(),
          );
      ref.invalidate(listaCorteProvider);
      ref.invalidate(clientesListProvider);
      if (!context.mounted) return;
      AppSnackbar.success(context, '${candidato.cliente.nombre} suspendido');
    } catch (e, stack) {
      appLogger.e('Error al suspender cliente', error: e, stackTrace: stack);
      if (!context.mounted) return;
      AppSnackbar.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.errorContainer,
        child: Text(
          '${candidato.cliente.codigo}',
          style: TextStyle(
            color: theme.colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        candidato.cliente.nombre,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${candidato.mesesConsecutivosEnMora} meses consecutivos · '
        '${candidato.cantidadFacturasLabel} · '
        '${candidato.diasVencidoMasViejo} días vencido',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatPesos(candidato.totalAdeudado),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.error,
            ),
          ),
          AppSpacing.gapMd,
          FilledButton.tonal(
            onPressed: () => _suspender(context, ref),
            child: const Text('Suspender'),
          ),
        ],
      ),
    );
  }
}

extension on CandidatoCorte {
  String get cantidadFacturasLabel => pluralES(
    facturasPendientes.length,
    'factura pendiente',
    'facturas pendientes',
  );
}
