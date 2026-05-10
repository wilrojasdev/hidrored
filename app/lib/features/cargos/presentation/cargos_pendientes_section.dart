import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../domain/entities/cargo_pendiente.dart';
import '../../../domain/entities/concepto.dart';
import '../../conceptos/presentation/conceptos_controller.dart';
import '../data/cargo_pendiente_repository.dart';

/// Sección incrustada en la ficha del cliente con sus cargos extras
/// pendientes de aplicar a la próxima factura. Permite agregar y
/// eliminar (solo si aún no se aplicaron).
class CargosPendientesSection extends ConsumerWidget {
  const CargosPendientesSection({super.key, required this.clienteId});
  final String clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncCargos = ref.watch(
      cargosPendientesPorClienteProvider(clienteId),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cargos extras pendientes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.gapXs,
                      Text(
                        'Conceptos del catálogo que se incluirán '
                        'automáticamente en el próximo recibo del cliente.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapMd,
                FilledButton.tonalIcon(
                  onPressed: () => _abrirAgregar(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            AppSpacing.gapLg,
            AsyncValueWidget<List<CargoPendiente>>(
              value: asyncCargos,
              onRetry: () =>
                  ref.invalidate(cargosPendientesPorClienteProvider(clienteId)),
              loading: const _CargosSkeleton(),
              data: (cargos) {
                if (cargos.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        AppSpacing.gapSm,
                        Expanded(
                          child: Text(
                            'Sin cargos pendientes. Cuando agregues uno '
                            'aparecerá aquí y entrará en el siguiente '
                            'recibo emitido.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final total = cargos.fold<int>(0, (s, c) => s + c.subtotal);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final c in cargos)
                      _CargoTile(cargo: c, clienteId: clienteId),
                    Divider(
                      height: AppSpacing.lg,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Total a sumar al próximo recibo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatPesos(total),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirAgregar(BuildContext context, WidgetRef ref) async {
    final asyncConceptos = await ref.read(conceptosListProvider.future);
    final activos = asyncConceptos.where((c) => c.activo).toList();
    if (!context.mounted) return;
    final result = await showDialog<_NuevoCargoData>(
      context: context,
      builder: (_) => _AgregarCargoDialog(conceptos: activos),
    );
    if (result == null || !context.mounted) return;
    try {
      await ref
          .read(cargoPendienteRepositoryProvider)
          .create(
            clienteId: clienteId,
            conceptoId: result.conceptoId,
            descripcion: result.descripcion,
            valorUnitario: result.valor,
            cantidad: result.cantidad,
            notas: result.notas,
          );
      ref.invalidate(cargosPendientesPorClienteProvider(clienteId));
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Cargo agregado');
    } catch (e, stack) {
      appLogger.e('Error al crear cargo', error: e, stackTrace: stack);
      if (!context.mounted) return;
      AppSnackbar.error(context, e);
    }
  }
}

class _CargoTile extends ConsumerWidget {
  const _CargoTile({required this.cargo, required this.clienteId});
  final CargoPendiente cargo;
  final String clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.label_outline,
              size: 18,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cargo.descripcion,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (cargo.notas != null && cargo.notas!.isNotEmpty)
                  Text(
                    cargo.notas!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  cargo.cantidad > 1
                      ? '${cargo.cantidad} × ${formatPesos(cargo.valorUnitario)}'
                      : formatPesos(cargo.valorUnitario),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
          Text(
            formatPesos(cargo.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          IconButton(
            tooltip: 'Quitar cargo',
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: () => _confirmarEliminar(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, WidgetRef ref) async {
    final ok = await confirm(
      context,
      titulo: 'Quitar cargo',
      mensaje:
          'Se quitará "${cargo.descripcion}" de los cargos pendientes. '
          'Si ya estaba aplicado a una factura no podrá borrarse.',
      confirmar: 'Quitar',
      tone: ConfirmTone.danger,
      icono: Icons.delete_outline,
    );
    if (!ok) return;
    try {
      await ref.read(cargoPendienteRepositoryProvider).delete(cargo.id);
      ref.invalidate(cargosPendientesPorClienteProvider(clienteId));
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Cargo quitado');
    } catch (e, stack) {
      appLogger.e('Error al quitar cargo', error: e, stackTrace: stack);
      if (!context.mounted) return;
      AppSnackbar.error(context, e);
    }
  }
}

class _CargosSkeleton extends StatelessWidget {
  const _CargosSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              SkeletonBox(width: 32, height: 32, borderRadius: 8),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 160, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 100, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 60, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Diálogo: agregar cargo
// ---------------------------------------------------------------------

class _NuevoCargoData {
  const _NuevoCargoData({
    required this.descripcion,
    required this.valor,
    required this.cantidad,
    this.conceptoId,
    this.notas,
  });
  final String descripcion;
  final int valor;
  final int cantidad;
  final String? conceptoId;
  final String? notas;
}

class _AgregarCargoDialog extends StatefulWidget {
  const _AgregarCargoDialog({required this.conceptos});
  final List<Concepto> conceptos;

  @override
  State<_AgregarCargoDialog> createState() => _AgregarCargoDialogState();
}

class _AgregarCargoDialogState extends State<_AgregarCargoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  final _valorCtrl = TextEditingController(text: '0');
  final _cantidadCtrl = TextEditingController(text: '1');
  final _notasCtrl = TextEditingController();
  Concepto? _conceptoSeleccionado;

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _valorCtrl.dispose();
    _cantidadCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _onConceptoChanged(Concepto? c) {
    setState(() {
      _conceptoSeleccionado = c;
      if (c != null) {
        _descripcionCtrl.text = c.nombre;
        _valorCtrl.text = formatPesosNoSymbol(c.valorDefault);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hayConceptos = widget.conceptos.isNotEmpty;
    return AlertDialog(
      title: const Text('Agregar cargo extra'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!hayConceptos)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      'No tienes conceptos activos en el catálogo. Puedes '
                      'crear el cargo manualmente o ir a "Conceptos" y '
                      'definir uno reusable.',
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<Concepto?>(
                    initialValue: _conceptoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Concepto del catálogo',
                      hintText: 'Opcional · solo para autollenar',
                    ),
                    items: [
                      const DropdownMenuItem<Concepto?>(
                        value: null,
                        child: Text('— Sin concepto —'),
                      ),
                      for (final c in widget.conceptos)
                        DropdownMenuItem(
                          value: c,
                          child: Text(
                            c.valorDefault > 0
                                ? '${c.nombre} · ${formatPesos(c.valorDefault)}'
                                : c.nombre,
                          ),
                        ),
                    ],
                    onChanged: _onConceptoChanged,
                  ),
                AppSpacing.gapMd,
                TextFormField(
                  controller: _descripcionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    hintText: 'Ej. Reconexión por cambio de manguera',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                ),
                AppSpacing.gapMd,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _valorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Valor unitario *',
                          prefixText: r'$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = parsePesos(v ?? '');
                          if (n == null) return 'Inválido';
                          if (n < 0) return 'No puede ser negativo';
                          return null;
                        },
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _cantidadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null) return 'Inválido';
                          if (n <= 0) return '> 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                TextFormField(
                  controller: _notasCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Detalles internos sobre este cargo',
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _onAgregar, child: const Text('Agregar')),
      ],
    );
  }

  void _onAgregar() {
    if (!_formKey.currentState!.validate()) return;
    final notas = _notasCtrl.text.trim();
    Navigator.pop(
      context,
      _NuevoCargoData(
        descripcion: _descripcionCtrl.text.trim(),
        valor: parsePesos(_valorCtrl.text) ?? 0,
        cantidad: int.parse(_cantidadCtrl.text.trim()),
        conceptoId: _conceptoSeleccionado?.id,
        notas: notas.isEmpty ? null : notas,
      ),
    );
  }
}
