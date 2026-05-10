import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../domain/entities/concepto.dart';
import '../data/concepto_repository.dart';
import 'conceptos_controller.dart';

class ConceptoFormScreen extends ConsumerWidget {
  const ConceptoFormScreen({super.key, this.id});
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
                onPressed: () => context.go('/conceptos'),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  isEdit ? 'Editar concepto' : 'Nuevo concepto',
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
                  maxWidth: AppSizes.formNarrowMaxWidth,
                ),
                child: isEdit ? _EditForm(id: id!) : const _ConceptoFormBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditForm extends ConsumerWidget {
  const _EditForm({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConcepto = ref.watch(conceptoDetailProvider(id));
    return AsyncValueWidget<Concepto>(
      value: asyncConcepto,
      onRetry: () => ref.invalidate(conceptoDetailProvider(id)),
      data: (c) => _ConceptoFormBody(initial: c),
    );
  }
}

class _ConceptoFormBody extends ConsumerStatefulWidget {
  const _ConceptoFormBody({this.initial});
  final Concepto? initial;

  @override
  ConsumerState<_ConceptoFormBody> createState() => _ConceptoFormBodyState();
}

class _ConceptoFormBodyState extends ConsumerState<_ConceptoFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _valorCtrl;
  late final TextEditingController _descripcionCtrl;
  late bool _activo;
  bool _saving = false;
  bool _dirty = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.initial?.nombre ?? '');
    _valorCtrl = TextEditingController(
      text: formatPesosNoSymbol(widget.initial?.valorDefault ?? 0),
    );
    _descripcionCtrl = TextEditingController(
      text: widget.initial?.descripcion ?? '',
    );
    _activo = widget.initial?.activo ?? true;
    for (final c in [_nombreCtrl, _valorCtrl, _descripcionCtrl]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _valorCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  String? _opt(String value) => value.trim().isEmpty ? null : value.trim();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(conceptoRepositoryProvider);
    try {
      final valor = parsePesos(_valorCtrl.text) ?? 0;
      if (_isEdit) {
        await repo.update(
          widget.initial!.id,
          nombre: _nombreCtrl.text.trim(),
          valorDefault: valor,
          descripcion: _opt(_descripcionCtrl.text),
          activo: _activo,
        );
      } else {
        await repo.create(
          nombre: _nombreCtrl.text.trim(),
          valorDefault: valor,
          descripcion: _opt(_descripcionCtrl.text),
        );
      }
      ref.invalidate(conceptosListProvider);
      if (!mounted) return;
      _dirty = false;
      AppSnackbar.success(
        context,
        _isEdit ? 'Concepto actualizado' : 'Concepto creado',
      );
      context.go('/conceptos');
    } catch (e, stack) {
      appLogger.e('Error al guardar concepto', error: e, stackTrace: stack);
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
          context.go('/conceptos');
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej. Reconexión, Mejora, Multa',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                AppSpacing.gapMd,
                MoneyField(
                  controller: _valorCtrl,
                  label: 'Valor por defecto',
                  helperText: 'Puedes cambiarlo al asignarlo a una factura',
                  enabled: !_saving,
                ),
                AppSpacing.gapMd,
                TextFormField(
                  controller: _descripcionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: '¿Cuándo se usa este concepto?',
                  ),
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                if (_isEdit) ...[
                  AppSpacing.gapMd,
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activo'),
                    subtitle: const Text(
                      'Solo los conceptos activos se pueden agregar a facturas',
                    ),
                    value: _activo,
                    onChanged: _saving
                        ? null
                        : (v) => setState(() {
                            _activo = v;
                            _dirty = true;
                          }),
                  ),
                ],
                AppSpacing.gapXxl,
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              if (await _onWillPop() && context.mounted) {
                                context.go('/conceptos');
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
        ),
      ),
    );
  }
}
