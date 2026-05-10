import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../domain/enums.dart';
import '../domain/ingresos_service.dart';

class IngresosTab extends ConsumerStatefulWidget {
  const IngresosTab({super.key});

  @override
  ConsumerState<IngresosTab> createState() => _IngresosTabState();
}

class _IngresosTabState extends ConsumerState<IngresosTab> {
  int _meses = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncIngresos = ref.watch(ingresosMensualesProvider(_meses));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncValueWidget<List<IngresosMensuales>>(
        value: asyncIngresos,
        onRetry: () => ref.invalidate(ingresosMensualesProvider(_meses)),
        data: (lista) {
          final totalPeriodo = lista.fold<int>(0, (s, m) => s + m.total);
          final mesActual = lista.lastOrNull;
          final maxValor = lista.fold<int>(
            0,
            (m, x) => x.total > m ? x.total : m,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector + KPIs
              Row(
                children: [
                  DropdownMenu<int>(
                    initialSelection: _meses,
                    label: const Text('Rango'),
                    width: 180,
                    onSelected: (v) {
                      if (v != null) setState(() => _meses = v);
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 3, label: 'Últimos 3 meses'),
                      DropdownMenuEntry(value: 6, label: 'Últimos 6 meses'),
                      DropdownMenuEntry(value: 12, label: 'Último año'),
                    ],
                  ),
                  const Spacer(),
                  _Kpi(
                    label: 'Total del periodo',
                    value: formatPesos(totalPeriodo),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 32),
                  _Kpi(
                    label: 'Mes actual',
                    value: formatPesos(mesActual?.total ?? 0),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Chart
              Expanded(
                flex: 3,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: lista.isEmpty
                        ? const Center(child: Text('Sin datos'))
                        : _IngresosChart(
                            ingresos: lista,
                            maxValor: maxValor.toDouble(),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Tabla por método
              Expanded(
                flex: 2,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text('Mes')),
                        for (final m in MetodoPago.values)
                          DataColumn(label: Text(m.label), numeric: true),
                        const DataColumn(label: Text('Total'), numeric: true),
                      ],
                      rows: [
                        for (final m in lista)
                          DataRow(
                            cells: [
                              DataCell(Text(formatPeriodo(m.periodo))),
                              for (final met in MetodoPago.values)
                                DataCell(Text(formatPesos(m.valorDe(met)))),
                              DataCell(
                                Text(
                                  formatPesos(m.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
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

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

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
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _IngresosChart extends StatelessWidget {
  const _IngresosChart({required this.ingresos, required this.maxValor});

  final List<IngresosMensuales> ingresos;
  final double maxValor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colores = {
      MetodoPago.bancolombia: Colors.blue.shade400,
      MetodoPago.nequi: Colors.purple.shade400,
      MetodoPago.efectivo: Colors.green.shade400,
      MetodoPago.otro: Colors.grey.shade400,
    };

    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final m in MetodoPago.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colores[m],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(m.label, style: theme.textTheme.bodySmall),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxValor * 1.15).clamp(1000, double.infinity),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxValor == 0 ? 1 : maxValor / 4,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 64,
                    interval: maxValor == 0 ? 1 : maxValor / 4,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        _abreviarMonto(v.toInt()),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= ingresos.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _periodoCorto(ingresos[i].periodo),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < ingresos.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: ingresos[i].total.toDouble(),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        rodStackItems: _stackItems(ingresos[i], colores),
                      ),
                    ],
                  ),
              ],
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, _) {
                    final m = ingresos[group.x];
                    return BarTooltipItem(
                      '${formatPeriodo(m.periodo)}\n',
                      const TextStyle(fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                          text: '${formatPesos(m.total)}\n',
                          style: const TextStyle(fontSize: 14),
                        ),
                        for (final met in MetodoPago.values)
                          if (m.valorDe(met) > 0)
                            TextSpan(
                              text:
                                  '${met.label}: ${formatPesos(m.valorDe(met))}\n',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartRodStackItem> _stackItems(
    IngresosMensuales mes,
    Map<MetodoPago, Color> colores,
  ) {
    var acum = 0.0;
    final stacks = <BarChartRodStackItem>[];
    for (final m in MetodoPago.values) {
      final v = mes.valorDe(m).toDouble();
      if (v <= 0) continue;
      stacks.add(BarChartRodStackItem(acum, acum + v, colores[m]!));
      acum += v;
    }
    return stacks;
  }

  String _abreviarMonto(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }

  String _periodoCorto(String periodo) {
    const meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final parts = periodo.split('-');
    if (parts.length != 2) return periodo;
    final m = int.tryParse(parts[1]) ?? 0;
    if (m < 1 || m > 12) return periodo;
    return '${meses[m]} ${parts[0].substring(2)}';
  }
}
