import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../domain/morosos_service.dart';
import 'ingresos_tab.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppSizes.mobileBreakpoint;
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? AppSpacing.lg : AppSpacing.xxl,
          isMobile ? AppSpacing.lg : AppSpacing.xxl,
          isMobile ? AppSpacing.lg : AppSpacing.xxl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reportes',
              style: isMobile
                  ? theme.textTheme.headlineSmall
                  : theme.textTheme.headlineMedium,
            ),
            AppSpacing.gapLg,
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Morosos'),
                Tab(icon: Icon(Icons.bar_chart), text: 'Ingresos'),
              ],
            ),
            const Expanded(
              child: TabBarView(children: [_MorososTab(), IngresosTab()]),
            ),
          ],
        ),
      ),
    );
  }
}

class _MorososTab extends ConsumerWidget {
  const _MorososTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMorosos = ref.watch(morososProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AsyncValueWidget<List<Moroso>>(
        value: asyncMorosos,
        onRetry: () => ref.invalidate(morososProvider),
        data: (lista) {
          if (lista.isEmpty) {
            return const AppEmptyState(
              icon: Icons.celebration_outlined,
              titulo: 'Sin morosos',
              descripcion: '¡Felicitaciones! Todos tus clientes están al día.',
            );
          }
          final totalAdeudado = lista.fold<int>(
            0,
            (s, m) => s + m.totalAdeudado,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Wrap(
                    spacing: AppSpacing.xxxl,
                    runSpacing: AppSpacing.lg,
                    children: [
                      _Stat(
                        label: pluralES(
                          lista.length,
                          'cliente moroso',
                          'clientes morosos',
                        ),
                        value: '${lista.length}',
                      ),
                      _Stat(
                        label: 'Total adeudado',
                        value: formatPesos(totalAdeudado),
                        colorEnfasis: true,
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = lista[i];
                      final theme = Theme.of(context);
                      return Semantics(
                        button: true,
                        label:
                            '${m.cliente.nombre}, debe ${formatPesos(m.totalAdeudado)} '
                            'en ${pluralES(m.cantidadFacturas, "factura", "facturas")}, '
                            '${m.diasMaxVencido} días vencido',
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.errorContainer,
                            child: Text(
                              '${m.cliente.codigo}',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            m.cliente.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${pluralES(m.cantidadFacturas, "factura", "facturas")} · '
                            '${m.diasMaxVencido} días vencido',
                          ),
                          trailing: Text(
                            formatPesos(m.totalAdeudado),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          onTap: () =>
                              context.go('/clientes/${m.cliente.id}/editar'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.colorEnfasis = false,
  });
  final String label;
  final String value;
  final bool colorEnfasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorEnfasis
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
