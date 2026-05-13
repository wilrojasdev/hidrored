import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/status_mappers.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/factura_linea.dart';
import '../../../domain/enums.dart';
import '../../clientes/presentation/clientes_controller.dart';
import '../../recibos/presentation/recibo_actions.dart';
import '../data/factura_repository.dart';
import 'facturas_controller.dart';

class FacturaDetalleScreen extends ConsumerWidget {
  const FacturaDetalleScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncFactura = ref.watch(facturaDetailProvider(id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/facturas'),
              ),
              const SizedBox(width: 8),
              Text('Detalle de factura', style: theme.textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AsyncValueWidget<Factura>(
              value: asyncFactura,
              onRetry: () => ref.invalidate(facturaDetailProvider(id)),
              data: (factura) => _DetailBody(factura: factura),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.factura});
  final Factura factura;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncCliente = ref.watch(clienteDetailProvider(factura.clienteId));
    final asyncLineas = ref.watch(facturaLineasProvider(factura.id));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          primary: false,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              maxWidth: constraints.maxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                factura.numero,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              StatusChip(
                                label: factura.estado.label,
                                variant: factura.estado.variant,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Periodo ${formatPeriodo(factura.periodo)} · '
                            '${factura.tipo.label}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${formatCedula(s.cedula)}${s.direccion == null ? '' : ' · ${s.direccion}'}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _Field(
                                  label: 'Emisión',
                                  value: formatFecha(factura.fechaEmision),
                                ),
                              ),
                              Expanded(
                                child: _Field(
                                  label: 'Vencimiento',
                                  value: formatFecha(factura.fechaVencimiento),
                                ),
                              ),
                            ],
                          ),
                          if (factura.estado == EstadoFactura.anulada &&
                              factura.motivoAnulacion != null) ...[
                            const SizedBox(height: 12),
                            _Field(
                              label: 'Motivo de anulación',
                              value: factura.motivoAnulacion!,
                            ),
                          ],
                          if (factura.estado == EstadoFactura.refacturada) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.merge_type,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Esta factura fue refacturada',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSecondaryContainer,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Su saldo se cobró en una factura '
                                          'posterior. No recibe nuevos pagos. '
                                          'Si necesitas revertir, anula la '
                                          'factura que la absorbió.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSecondaryContainer,
                                              ),
                                        ),
                                        if (factura.refacturadaEnId !=
                                            null) ...[
                                          const SizedBox(height: 8),
                                          InkWell(
                                            onTap: () => context.go(
                                              '/facturas/${factura.refacturadaEnId}',
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.arrow_forward,
                                                  size: 14,
                                                  color: theme
                                                      .colorScheme
                                                      .onSecondaryContainer,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Ver factura que la absorbió',
                                                  style: TextStyle(
                                                    color: theme
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          Text('Conceptos', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          AsyncValueWidget<List<FacturaLinea>>(
                            value: asyncLineas,
                            data: (lineas) => Column(
                              children: [
                                for (final l in lineas) _LineaRow(linea: l),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Text(
                                      formatPesos(factura.total),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => ReciboActions.imprimirIndividual(
                          context,
                          ref,
                          factura,
                        ),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Imprimir / Vista previa'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => ReciboActions.compartirIndividual(
                          context,
                          ref,
                          factura,
                        ),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Compartir PDF'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => ReciboActions.mensajeWhatsApp(
                          context,
                          ref,
                          factura,
                        ),
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Mensaje WhatsApp'),
                      ),
                      if (factura.estado == EstadoFactura.pendiente)
                        OutlinedButton.icon(
                          onPressed: () => _anular(context, ref),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Anular factura'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        ),
                      if (factura.estado == EstadoFactura.anulada)
                        FilledButton.icon(
                          onPressed: () => context.go(
                            '/facturas/individual/${factura.clienteId}'
                            '?periodo=${factura.periodo}',
                          ),
                          icon: const Icon(Icons.replay),
                          label: const Text('Re-emitir factura'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _anular(BuildContext context, WidgetRef ref) async {
    final motivoCtrl = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Anular factura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'La factura quedará anulada y no se cobrará. Si era un error '
              'puedes re-emitirla desde "Generar mes".',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivoCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Motivo (obligatorio)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, motivoCtrl.text.trim()),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
    if (motivo == null || motivo.isEmpty) return;
    try {
      await ref
          .read(facturaRepositoryProvider)
          .anular(factura.id, motivo: motivo);
      ref.invalidate(facturaDetailProvider(factura.id));
      ref.invalidate(facturasListProvider);
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Factura anulada');
    } catch (e, stack) {
      appLogger.e('Error al anular factura', error: e, stackTrace: stack);
      if (!context.mounted) return;
      AppSnackbar.error(context, e);
    }
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

class _LineaRow extends StatelessWidget {
  const _LineaRow({required this.linea});
  final FacturaLinea linea;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esRefacturada = linea.facturaOrigenId != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (esRefacturada) ...[
            Tooltip(
              message: 'Saldo refacturado de una factura anterior',
              child: Icon(
                Icons.history,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(linea.descripcion),
                if (esRefacturada)
                  Text(
                    'Refacturado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (linea.cantidad > 1) ...[
            Text('${linea.cantidad}× '),
            const SizedBox(width: 8),
          ],
          Text(
            formatPesos(linea.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
