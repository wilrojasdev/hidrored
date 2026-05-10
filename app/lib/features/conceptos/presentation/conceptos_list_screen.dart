import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../domain/entities/concepto.dart';
import '../data/concepto_repository.dart';
import 'conceptos_controller.dart';

class ConceptosListScreen extends ConsumerWidget {
  const ConceptosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncList = ref.watch(conceptosListProvider);
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
                Text('Conceptos', style: theme.textTheme.headlineSmall),
                AppSpacing.gapSm,
                FilledButton.icon(
                  onPressed: () => context.go('/conceptos/nuevo'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo concepto'),
                ),
              ],
            )
          else
            Row(
              children: [
                Text('Conceptos', style: theme.textTheme.headlineMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/conceptos/nuevo'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo concepto'),
                ),
              ],
            ),
          AppSpacing.gapXs,
          Text(
            'Catálogo de cargos extra (reconexión, mejoras, multas...) que '
            'puedes asignar a una factura.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapLg,
          Expanded(
            child: AsyncValueWidget<List<Concepto>>(
              value: asyncList,
              onRetry: () => ref.invalidate(conceptosListProvider),
              loading: const _ConceptosSkeleton(),
              data: (lista) {
                if (lista.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.list_alt_outlined,
                    titulo: 'Sin conceptos aún',
                    descripcion:
                        'Crea conceptos como "Reconexión", "Mejora de tubería" '
                        'o "Multa por mal uso" para sumarlos a las facturas.',
                    acciones: [
                      FilledButton.icon(
                        onPressed: () => context.go('/conceptos/nuevo'),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear primer concepto'),
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(conceptosListProvider);
                    await ref.read(conceptosListProvider.future);
                  },
                  child: ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) =>
                        _ConceptoTile(concepto: lista[i]),
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

class _ConceptosSkeleton extends StatelessWidget {
  const _ConceptosSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => const ListTileSkeleton(),
    );
  }
}

class _ConceptoTile extends ConsumerWidget {
  const _ConceptoTile({required this.concepto});
  final Concepto concepto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label:
          '${concepto.nombre}, ${concepto.activo ? "activo" : "inactivo"}, '
          '${concepto.valorDefault > 0 ? "valor por defecto ${formatPesos(concepto.valorDefault)}" : "sin valor por defecto"}',
      child: ListTile(
        leading: Icon(
          concepto.activo ? Icons.label : Icons.label_off_outlined,
          color: concepto.activo
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          semanticLabel: concepto.activo ? 'Activo' : 'Inactivo',
        ),
        title: Text(
          concepto.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: concepto.activo
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: concepto.descripcion == null
            ? null
            : Text(concepto.descripcion!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (concepto.valorDefault > 0)
              Text(
                formatPesos(concepto.valorDefault),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            AppSpacing.gapMd,
            Switch(
              value: concepto.activo,
              onChanged: (v) async {
                try {
                  await ref
                      .read(conceptoRepositoryProvider)
                      .toggleActivo(concepto.id, v);
                  ref.invalidate(conceptosListProvider);
                  if (context.mounted) {
                    AppSnackbar.success(
                      context,
                      v ? 'Concepto activado' : 'Concepto desactivado',
                    );
                  }
                } catch (e) {
                  if (context.mounted) AppSnackbar.error(context, e);
                }
              },
            ),
            AppSpacing.gapSm,
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.go('/conceptos/${concepto.id}/editar'),
      ),
    );
  }
}
