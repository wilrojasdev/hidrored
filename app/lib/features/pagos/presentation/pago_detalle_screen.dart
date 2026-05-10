import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/entities/pago_factura.dart';
import '../../../domain/entities/cliente.dart';
import '../../facturacion/presentation/facturas_controller.dart';
import '../../clientes/presentation/clientes_controller.dart';
import 'pagos_controller.dart';

class PagoDetalleScreen extends ConsumerWidget {
  const PagoDetalleScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncPago = ref.watch(pagoDetailProvider(id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/pagos'),
              ),
              const SizedBox(width: 8),
              Text('Detalle de pago', style: theme.textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AsyncValueWidget<Pago>(
              value: asyncPago,
              onRetry: () => ref.invalidate(pagoDetailProvider(id)),
              data: (pago) => _Body(pago: pago),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.pago});
  final Pago pago;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncCliente = ref.watch(clienteDetailProvider(pago.clienteId));
    final asyncAplicaciones = ref.watch(aplicacionesDePagoProvider(pago.id));

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          formatPesos(pago.valor),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pago.metodo.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatFecha(pago.fecha),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 32),
                    AsyncValueWidget<Cliente>(
                      value: asyncCliente,
                      data: (s) => Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  formatCedula(s.cedula),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pago.referencia != null) ...[
                      const SizedBox(height: 12),
                      _Field(label: 'Referencia', value: pago.referencia!),
                    ],
                    if (pago.notas != null) ...[
                      const SizedBox(height: 12),
                      _Field(label: 'Notas', value: pago.notas!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facturas afectadas',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    AsyncValueWidget<List<PagoFactura>>(
                      value: asyncAplicaciones,
                      data: (lista) {
                        if (lista.isEmpty) {
                          return Text(
                            'Este pago no se aplicó a ninguna factura.',
                            style: theme.textTheme.bodyMedium,
                          );
                        }
                        return Column(
                          children: [
                            for (final pf in lista)
                              _AplicacionRow(pagoFactura: pf),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AplicacionRow extends ConsumerWidget {
  const _AplicacionRow({required this.pagoFactura});
  final PagoFactura pagoFactura;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFactura = ref.watch(
      facturaDetailProvider(pagoFactura.facturaId),
    );
    return asyncFactura.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (factura) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => context.go('/facturas/${factura.id}'),
                child: Text(
                  '${factura.numero} · ${formatPeriodo(factura.periodo)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Text(
              formatPesos(pagoFactura.montoAplicado),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

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
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
