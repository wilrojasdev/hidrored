import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/extensions/formato.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/clock.dart';
import '../../core/widgets/app_async_value.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../auth/presentation/auth_controller.dart';
import '../servicio/domain/lista_corte_service.dart';
import 'domain/dashboard_stats_service.dart';

String _capitalizar(String texto) {
  if (texto.isEmpty) return texto;
  return texto[0].toUpperCase() + texto.substring(1);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final perfil = ref.watch(perfilProvider).valueOrNull;
    final asyncStats = ref.watch(dashboardStatsProvider);
    final asyncCorte = ref.watch(listaCorteProvider);
    final hoy = BogotaClock.hoy();
    final mesActual = DateFormat('MMMM y', 'es_CO').format(hoy);
    final fechaHoy = DateFormat("EEEE d 'de' MMMM", 'es_CO').format(hoy);
    final hora = DateTime.now().hour;
    final saludo = hora < 12
        ? 'Buenos días'
        : hora < 19
        ? 'Buenas tardes'
        : 'Buenas noches';
    final primerNombre = (perfil?.nombre ?? '').split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perfil != null
                          ? '$saludo, $primerNombre'
                          : 'Resumen del acueducto',
                      style: theme.textTheme.headlineMedium,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      _capitalizar(fechaHoy),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      _capitalizar(mesActual),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapXxl,
          AsyncValueWidget<DashboardStats>(
            value: asyncStats,
            onRetry: () => ref.invalidate(dashboardStatsProvider),
            loading: const _DashboardSkeleton(),
            data: (stats) {
              if (stats.totalClientes == 0) {
                return const _OnboardingCard();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KpiGrid(
                    stats: stats,
                    candidatosCorte: asyncCorte.valueOrNull?.length ?? 0,
                  ),
                  AppSpacing.gapXxl,
                  _AccesosRapidos(
                    candidatosCorte: asyncCorte.valueOrNull?.length ?? 0,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: cols,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          shrinkWrap: true,
          childAspectRatio: 1.7,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            KpiSkeleton(),
            KpiSkeleton(),
            KpiSkeleton(),
            KpiSkeleton(),
            KpiSkeleton(),
            KpiSkeleton(),
          ],
        );
      },
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                AppSpacing.gapMd,
                Text(
                  'Empieza con tu acueducto',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,
            Text(
              'Para empezar a usar HidroRed sigue estos pasos:',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapXl,
            _OnboardingStep(
              numero: 1,
              titulo: 'Configura los datos del acueducto',
              descripcion:
                  'NIT, prefijo de recibos, cuentas Bancolombia/Nequi y tarifa básica.',
              accion: OutlinedButton.icon(
                onPressed: () => context.go('/configuracion'),
                icon: const Icon(Icons.settings),
                label: const Text('Ir a configuración'),
              ),
            ),
            AppSpacing.gapLg,
            _OnboardingStep(
              numero: 2,
              titulo: 'Carga tus clientes',
              descripcion:
                  'Importa desde un archivo de Excel o crea uno por uno.',
              accion: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/clientes/importar'),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importar Excel'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/clientes/nuevo'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Crear cliente'),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,
            const _OnboardingStep(
              numero: 3,
              titulo: 'Genera la facturación del mes',
              descripcion:
                  'Cuando tengas clientes activos podrás emitir las facturas e imprimir recibos.',
              accion: SizedBox.shrink(),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.accion,
    this.isLast = false,
  });
  final int numero;
  final String titulo;
  final String descripcion;
  final Widget accion;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$numero',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppSpacing.gapLg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapXs,
              Text(
                descripcion,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (!isLast) ...[AppSpacing.gapMd, accion],
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.stats, required this.candidatosCorte});
  final DashboardStats stats;
  final int candidatosCorte;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: columnas,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          shrinkWrap: true,
          childAspectRatio: 1.7,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _KpiCard(
              icon: Icons.people,
              colorBuilder: AppSemanticColors.info,
              label: 'Clientes activos',
              value: '${stats.clientesActivos}',
              hint: pluralES(stats.totalClientes, 'en total', 'en total'),
              hintFull: '${stats.totalClientes} en total',
            ),
            _KpiCard(
              icon: Icons.attach_money,
              colorBuilder: AppSemanticColors.success,
              label: 'Recaudo del mes',
              value: formatPesos(stats.recaudoMes),
              hint: pluralES(
                stats.cantidadPagosMes,
                'pago registrado',
                'pagos registrados',
              ),
              hintFull: pluralES(
                stats.cantidadPagosMes,
                'pago registrado',
                'pagos registrados',
              ),
            ),
            _KpiCard(
              icon: Icons.warning_amber,
              colorBuilder: AppSemanticColors.danger,
              label: 'Cartera pendiente',
              value: formatPesos(stats.totalAdeudado),
              hint: pluralES(
                stats.facturasPendientes,
                'factura pendiente',
                'facturas pendientes',
              ),
              hintFull: pluralES(
                stats.facturasPendientes,
                'factura pendiente',
                'facturas pendientes',
              ),
            ),
            _KpiCard(
              icon: Icons.block,
              colorBuilder: AppSemanticColors.warning,
              label: 'Suspendidos',
              value: '${stats.clientesSuspendidos}',
              hint: 'Por mora o voluntario',
              hintFull: 'Por mora o voluntario',
            ),
            _KpiCard(
              icon: Icons.cut,
              colorBuilder: AppSemanticColors.danger,
              label: 'Lista de corte',
              value: '$candidatosCorte',
              hint: pluralES(
                candidatosCorte,
                'candidato a suspender',
                'candidatos a suspender',
              ),
              hintFull: pluralES(
                candidatosCorte,
                'candidato a suspender',
                'candidatos a suspender',
              ),
            ),
            _KpiCard(
              icon: Icons.build,
              colorBuilder: AppSemanticColors.warning,
              label: 'Daños activos',
              value: '${stats.danosActivos}',
              hint: 'Reportados o en reparación',
              hintFull: 'Reportados o en reparación',
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.colorBuilder,
    required this.label,
    required this.value,
    required this.hint,
    required this.hintFull,
  });

  final IconData icon;
  final Color Function(BuildContext) colorBuilder;
  final String label;
  final String value;
  final String hint;
  final String hintFull;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = colorBuilder(context);
    return Semantics(
      container: true,
      label: '$label: $value. $hintFull',
      child: Card(
        child: Stack(
          children: [
            Positioned(
              right: -12,
              top: -12,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(icon, color: color, semanticLabel: label),
                  ),
                  AppSpacing.gapSm,
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccesosRapidos extends StatelessWidget {
  const _AccesosRapidos({required this.candidatosCorte});
  final int candidatosCorte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accesos rápidos', style: theme.textTheme.titleMedium),
            AppSpacing.gapMd,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _Acceso(
                  icon: Icons.playlist_add_check,
                  label: 'Generar facturación del mes',
                  onTap: () => context.go('/facturas/generar'),
                ),
                _Acceso(
                  icon: Icons.payments,
                  label: 'Registrar pago',
                  onTap: () => context.go('/pagos/nuevo'),
                ),
                _Acceso(
                  icon: Icons.warning_amber,
                  label: 'Ver morosos',
                  onTap: () => context.go('/reportes'),
                ),
                _Acceso(
                  icon: Icons.cut,
                  label: candidatosCorte > 0
                      ? 'Lista de corte ($candidatosCorte)'
                      : 'Lista de corte',
                  onTap: () => context.go('/servicio'),
                  highlight: candidatosCorte > 0,
                ),
                _Acceso(
                  icon: Icons.person_add,
                  label: 'Nuevo cliente',
                  onTap: () => context.go('/clientes/nuevo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Acceso extends StatelessWidget {
  const _Acceso({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    if (highlight) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
