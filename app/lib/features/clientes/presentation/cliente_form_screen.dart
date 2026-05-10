import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/tenant_provider.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/enums.dart';
import '../../cargos/presentation/cargos_pendientes_section.dart';
import '../../recibos/presentation/estado_cuenta_actions.dart';
import '../data/cliente_repository.dart';
import 'clientes_controller.dart';

class ClienteFormScreen extends ConsumerWidget {
  const ClienteFormScreen({super.key, this.id});

  /// Si `id` es null, es modo creacion. Si tiene valor, es edicion.
  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = id != null;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Volver',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/clientes'),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  isEdit ? 'Editar cliente' : 'Nuevo cliente',
                  style: theme.textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.formMaxWidth,
                ),
                child: isEdit ? _EditForm(id: id!) : const _CreateForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateForm extends ConsumerWidget {
  const _CreateForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCodigo = ref.watch(nextCodigoProvider);
    final asyncTenant = ref.watch(tenantProvider);
    return AsyncValueWidget<int>(
      value: asyncCodigo,
      onRetry: () => ref.invalidate(nextCodigoProvider),
      data: (codigo) => AsyncValueWidget<Tenant>(
        value: asyncTenant,
        onRetry: () => ref.invalidate(tenantProvider),
        data: (tenant) =>
            _ClienteFormBody(initialCodigo: codigo, tenant: tenant),
      ),
    );
  }
}

class _EditForm extends ConsumerWidget {
  const _EditForm({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCliente = ref.watch(clienteDetailProvider(id));
    final asyncTenant = ref.watch(tenantProvider);
    return AsyncValueWidget<Cliente>(
      value: asyncCliente,
      onRetry: () => ref.invalidate(clienteDetailProvider(id)),
      data: (s) => AsyncValueWidget<Tenant>(
        value: asyncTenant,
        onRetry: () => ref.invalidate(tenantProvider),
        data: (tenant) => _ClienteFormBody(initial: s, tenant: tenant),
      ),
    );
  }
}

class _ClienteFormBody extends ConsumerStatefulWidget {
  const _ClienteFormBody({
    this.initial,
    this.initialCodigo,
    required this.tenant,
  });
  final Cliente? initial;
  final int? initialCodigo;
  final Tenant tenant;

  @override
  ConsumerState<_ClienteFormBody> createState() => _ClienteFormBodyState();
}

class _ClienteFormBodyState extends ConsumerState<_ClienteFormBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codigoCtrl;
  late final TextEditingController _cedulaCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _sectorCtrl;
  late final TextEditingController _zonaCtrl;
  late final TextEditingController _barrioCtrl;
  late final TextEditingController _tarifaCtrl;
  late final TextEditingController _deudaCtrl;
  late final TextEditingController _notasCtrl;
  late EstadoCliente _estado;
  late int _tarifaActual;
  bool _saving = false;
  bool _dirty = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _codigoCtrl = TextEditingController(
      text: '${s?.codigo ?? widget.initialCodigo ?? 1}',
    );
    _cedulaCtrl = TextEditingController(
      text: s?.cedula == null ? '' : formatCedula(s!.cedula),
    );
    _nombreCtrl = TextEditingController(text: s?.nombre ?? '');
    _direccionCtrl = TextEditingController(text: s?.direccion ?? '');
    _telefonoCtrl = TextEditingController(
      text: s?.telefono == null ? '' : formatTelefono(s!.telefono!),
    );
    _sectorCtrl = TextEditingController(text: s?.sector ?? '');
    _zonaCtrl = TextEditingController(text: s?.zona ?? '');
    _barrioCtrl = TextEditingController(text: s?.barrio ?? '');
    _tarifaCtrl = TextEditingController(
      text: formatPesosNoSymbol(s?.tarifaMensual ?? widget.tenant.tarifaBasica),
    );
    _tarifaCtrl.addListener(_onTarifaChanged);
    _deudaCtrl = TextEditingController(
      text: formatPesosNoSymbol(s?.deudaInicial ?? 0),
    );
    _notasCtrl = TextEditingController(text: s?.notas ?? '');
    _estado = s?.estado ?? EstadoCliente.activo;
    _tarifaActual = s?.tarifaMensual ?? widget.tenant.tarifaBasica;

    for (final c in [
      _codigoCtrl,
      _cedulaCtrl,
      _nombreCtrl,
      _direccionCtrl,
      _telefonoCtrl,
      _sectorCtrl,
      _zonaCtrl,
      _barrioCtrl,
      _tarifaCtrl,
      _deudaCtrl,
      _notasCtrl,
    ]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  /// Refresca el indicador de chip seleccionado cuando cambia el valor del
  /// campo tarifa, ya sea por click en chip o porque el admin escribió un
  /// valor distinto a mano.
  void _onTarifaChanged() {
    final v = parsePesos(_tarifaCtrl.text) ?? 0;
    if (v != _tarifaActual && mounted) {
      setState(() => _tarifaActual = v);
    }
  }

  /// Selecciona una de las tarifas configuradas (básica/extendida).
  void _setTarifa(int valor) {
    _tarifaCtrl.text = formatPesosNoSymbol(valor);
    _markDirty();
  }

  @override
  void dispose() {
    _tarifaCtrl.removeListener(_onTarifaChanged);
    for (final c in [
      _codigoCtrl,
      _cedulaCtrl,
      _nombreCtrl,
      _direccionCtrl,
      _telefonoCtrl,
      _sectorCtrl,
      _zonaCtrl,
      _barrioCtrl,
      _tarifaCtrl,
      _deudaCtrl,
      _notasCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(String value) => value.trim().isEmpty ? null : value.trim();

  String? _digits(String value) {
    final d = value.replaceAll(RegExp(r'[^0-9]'), '');
    return d.isEmpty ? null : d;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(clienteRepositoryProvider);
    try {
      final cedulaDigits = _cedulaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      final tarifa = parsePesos(_tarifaCtrl.text) ?? 0;
      final deuda = parsePesos(_deudaCtrl.text) ?? 0;
      final telefonoDigits = _digits(_telefonoCtrl.text);
      if (_isEdit) {
        await repo.update(
          widget.initial!.id,
          cedula: cedulaDigits,
          nombre: _nombreCtrl.text.trim(),
          direccion: _opt(_direccionCtrl.text),
          telefono: telefonoDigits,
          sector: _opt(_sectorCtrl.text),
          zona: _opt(_zonaCtrl.text),
          barrio: _opt(_barrioCtrl.text),
          tarifaMensual: tarifa,
          estado: _estado,
          deudaInicial: deuda,
          notas: _opt(_notasCtrl.text),
        );
      } else {
        await repo.create(
          codigo: int.parse(_codigoCtrl.text),
          cedula: cedulaDigits,
          nombre: _nombreCtrl.text.trim(),
          direccion: _opt(_direccionCtrl.text),
          telefono: telefonoDigits,
          sector: _opt(_sectorCtrl.text),
          zona: _opt(_zonaCtrl.text),
          barrio: _opt(_barrioCtrl.text),
          tarifaMensual: tarifa,
          estado: _estado,
          deudaInicial: deuda,
          notas: _opt(_notasCtrl.text),
        );
      }
      ref.invalidate(clientesListProvider);
      if (!mounted) return;
      _dirty = false;
      AppSnackbar.success(
        context,
        _isEdit ? 'Cliente actualizado' : 'Cliente creado',
      );
      context.go('/clientes');
    } catch (e, stack) {
      appLogger.e('Error al guardar cliente', error: e, stackTrace: stack);
      if (!mounted) return;
      AppSnackbar.error(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _retirar() async {
    final ok = await confirm(
      context,
      titulo: 'Retirar cliente',
      mensaje:
          'El cliente ${widget.initial!.nombre} quedará marcado como retirado. '
          'Su histórico se conserva y no se le emitirán nuevas facturas. '
          'Puedes reactivarlo después cambiando su estado.',
      confirmar: 'Retirar',
      tone: ConfirmTone.danger,
      icono: Icons.person_off_outlined,
    );
    if (!ok) return;
    setState(() => _saving = true);
    try {
      await ref.read(clienteRepositoryProvider).retirar(widget.initial!.id);
      ref.invalidate(clientesListProvider);
      if (!mounted) return;
      _dirty = false;
      AppSnackbar.success(context, 'Cliente retirado');
      context.go('/clientes');
    } catch (e, stack) {
      appLogger.e('Error al retirar cliente', error: e, stackTrace: stack);
      if (!mounted) return;
      AppSnackbar.error(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_dirty || _saving) return true;
    return confirmDiscardChanges(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onWillPop() && context.mounted) {
          context.go('/clientes');
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(
              titulo: 'Identificación',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _codigoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Código *',
                          helperText: 'Interno del acueducto',
                        ),
                        enabled: !_isEdit && !_saving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _requiredInt,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      flex: 2,
                      child: CedulaField(
                        controller: _cedulaCtrl,
                        enabled: !_saving,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  validator: _required,
                ),
              ],
            ),
            _Section(
              titulo: 'Ubicación',
              children: [
                TextFormField(
                  controller: _direccionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    hintText: 'Ej. MZ 2 CASA 8',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.characters,
                ),
                AppSpacing.gapMd,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sectorCtrl,
                        decoration: const InputDecoration(labelText: 'Sector'),
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _zonaCtrl,
                        decoration: const InputDecoration(labelText: 'Zona'),
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _barrioCtrl,
                        decoration: const InputDecoration(labelText: 'Barrio'),
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              titulo: 'Contacto',
              children: [
                TelefonoField(controller: _telefonoCtrl, enabled: !_saving),
              ],
            ),
            _Section(
              titulo: 'Facturación',
              children: [
                _TarifaSelector(
                  basica: widget.tenant.tarifaBasica,
                  extendida: widget.tenant.tarifaExtendida,
                  actual: _tarifaActual,
                  enabled: !_saving,
                  onSelect: _setTarifa,
                ),
                AppSpacing.gapSm,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MoneyField(
                        controller: _tarifaCtrl,
                        label: 'Tarifa mensual',
                        required: true,
                        allowZero: false,
                        enabled: !_saving,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: MoneyField(
                        controller: _deudaCtrl,
                        label: 'Deuda inicial',
                        helperText: 'Saldo previo al ingresar al sistema',
                        enabled: !_saving,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                DropdownButtonFormField<EstadoCliente>(
                  initialValue: _estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  onChanged: _saving
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() {
                              _estado = v;
                              _dirty = true;
                            });
                          }
                        },
                  items: [
                    for (final estado in EstadoCliente.values)
                      DropdownMenuItem(
                        value: estado,
                        child: Text(estado.label),
                      ),
                  ],
                ),
              ],
            ),
            _Section(
              titulo: 'Notas',
              children: [
                TextFormField(
                  controller: _notasCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText:
                        'Comentarios, ubicación de medidor, observaciones...',
                  ),
                  enabled: !_saving,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            if (_isEdit) CargosPendientesSection(clienteId: widget.initial!.id),
            AppSpacing.gapXxl,
            if (_isEdit)
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _saving
                        ? null
                        : () => context.go(
                            '/facturas/individual/${widget.initial!.id}',
                          ),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Generar factura individual'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => EstadoCuentaActions.imprimir(
                            context,
                            ref,
                            widget.initial!.id,
                          ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Estado de cuenta PDF'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => EstadoCuentaActions.compartir(
                            context,
                            ref,
                            widget.initial!.id,
                          ),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Compartir'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _retirar,
                    icon: const Icon(Icons.person_off_outlined),
                    label: const Text('Retirar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            AppSpacing.gapLg,
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (await _onWillPop() && context.mounted) {
                            context.go('/clientes');
                          }
                        },
                  child: const Text('Cancelar'),
                ),
                AppSpacing.gapMd,
                FilledButton.icon(
                  onPressed: _saving ? null : _guardar,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Guardando...' : 'Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  String? _requiredInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Debe ser un número';
    if (n < 0) return 'No puede ser negativo';
    return null;
  }
}

/// Atajos para asignar una de las dos tarifas configuradas en el tenant.
/// El admin puede escribir un valor distinto a mano: en ese caso ningún
/// chip queda seleccionado (estado "personalizada"). Al hacer click en un
/// chip se autollenan el TextField y la tarifa actual.
class _TarifaSelector extends StatelessWidget {
  const _TarifaSelector({
    required this.basica,
    required this.extendida,
    required this.actual,
    required this.enabled,
    required this.onSelect,
  });

  final int basica;
  final int extendida;
  final int actual;
  final bool enabled;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esBasica = actual == basica;
    final esExtendida = actual == extendida;
    final esPersonalizada = !esBasica && !esExtendida;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarifa configurada',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapXs,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.water_drop_outlined, size: 18),
              label: Text('Básica · ${formatPesos(basica)}'),
              selected: esBasica,
              onSelected: enabled && !esBasica ? (_) => onSelect(basica) : null,
            ),
            ChoiceChip(
              avatar: const Icon(Icons.water_drop, size: 18),
              label: Text('Extendida · ${formatPesos(extendida)}'),
              selected: esExtendida,
              onSelected: enabled && !esExtendida
                  ? (_) => onSelect(extendida)
                  : null,
            ),
            if (esPersonalizada)
              Chip(
                avatar: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                label: const Text('Personalizada'),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
              ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titulo, required this.children});
  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titulo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.gapLg,
            ...children,
          ],
        ),
      ),
    );
  }
}
