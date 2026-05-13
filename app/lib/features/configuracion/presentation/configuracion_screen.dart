import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/tenant_provider.dart';
import '../../../domain/entities/tenant.dart';
import '../../backup/presentation/backup_card.dart';
import '../data/tenant_repository.dart';

class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncTenant = ref.watch(tenantProvider);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppSizes.mobileBreakpoint;

    return Padding(
      padding: isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Configuración',
            style: isMobile
                ? theme.textTheme.headlineSmall
                : theme.textTheme.headlineMedium,
          ),
          AppSpacing.gapXs,
          Text(
            'Datos del acueducto, tarifas por defecto y reglas de facturación.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapLg,
          Expanded(
            child: AsyncValueWidget<Tenant>(
              value: asyncTenant,
              onRetry: () => ref.invalidate(tenantProvider),
              data: (t) => LayoutBuilder(
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ConfigForm(tenant: t),
                            AppSpacing.gapLg,
                            const BackupCard(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigForm extends ConsumerStatefulWidget {
  const _ConfigForm({required this.tenant});
  final Tenant tenant;

  @override
  ConsumerState<_ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends ConsumerState<_ConfigForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _nitCtrl;
  late final TextEditingController _representanteCtrl;
  late final TextEditingController _prefijoCtrl;
  late final TextEditingController _bancolombiaCtrl;
  late final TextEditingController _nequiCtrl;
  late final TextEditingController _moraCtrl;
  late final TextEditingController _reconexionCtrl;
  late final TextEditingController _tarifaBasicaCtrl;
  late final TextEditingController _tarifaExtCtrl;
  late final TextEditingController _diasCtrl;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tenant;
    _nombreCtrl = TextEditingController(text: t.nombre);
    _nitCtrl = TextEditingController(text: t.nit ?? '');
    _representanteCtrl = TextEditingController(
      text: t.representanteLegal ?? '',
    );
    _prefijoCtrl = TextEditingController(text: t.prefijoRecibos);
    _bancolombiaCtrl = TextEditingController(text: t.cuentaBancolombia ?? '');
    _nequiCtrl = TextEditingController(text: t.cuentaNequi ?? '');
    _moraCtrl = TextEditingController(
      text: formatPesosNoSymbol(t.tarifaMoraDiaria),
    );
    _reconexionCtrl = TextEditingController(
      text: formatPesosNoSymbol(t.costoReconexion),
    );
    _tarifaBasicaCtrl = TextEditingController(
      text: formatPesosNoSymbol(t.tarifaBasica),
    );
    _tarifaExtCtrl = TextEditingController(
      text: formatPesosNoSymbol(t.tarifaExtendida),
    );
    _diasCtrl = TextEditingController(text: '${t.diasHabilesPago}');

    for (final c in [
      _nombreCtrl,
      _nitCtrl,
      _representanteCtrl,
      _prefijoCtrl,
      _bancolombiaCtrl,
      _nequiCtrl,
      _moraCtrl,
      _reconexionCtrl,
      _tarifaBasicaCtrl,
      _tarifaExtCtrl,
      _diasCtrl,
    ]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    for (final c in [
      _nombreCtrl,
      _nitCtrl,
      _representanteCtrl,
      _prefijoCtrl,
      _bancolombiaCtrl,
      _nequiCtrl,
      _moraCtrl,
      _reconexionCtrl,
      _tarifaBasicaCtrl,
      _tarifaExtCtrl,
      _diasCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(String value) => value.trim().isEmpty ? null : value.trim();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(tenantRepositoryProvider)
          .update(
            nombre: _nombreCtrl.text.trim(),
            nit: _opt(_nitCtrl.text),
            representanteLegal: _opt(_representanteCtrl.text),
            prefijoRecibos: _prefijoCtrl.text.trim(),
            cuentaBancolombia: _opt(_bancolombiaCtrl.text),
            cuentaNequi: _opt(_nequiCtrl.text),
            tarifaMoraDiaria: parsePesos(_moraCtrl.text) ?? 0,
            costoReconexion: parsePesos(_reconexionCtrl.text) ?? 0,
            tarifaBasica: parsePesos(_tarifaBasicaCtrl.text) ?? 0,
            tarifaExtendida: parsePesos(_tarifaExtCtrl.text) ?? 0,
            diasHabilesPago: int.parse(_diasCtrl.text),
          );
      ref.invalidate(tenantProvider);
      if (!mounted) return;
      _dirty = false;
      AppSnackbar.success(context, 'Configuración actualizada');
    } catch (e, stack) {
      appLogger.e(
        'Error al guardar configuración',
        error: e,
        stackTrace: stack,
      );
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
        await _onWillPop();
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(
              titulo: 'Datos del acueducto',
              descripcion: 'Aparecen impresos en cada recibo del cliente.',
              children: [
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    prefixIcon: Icon(Icons.water_drop_outlined),
                  ),
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  validator: _required,
                ),
                AppSpacing.gapMd,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nitCtrl,
                        decoration: const InputDecoration(
                          labelText: 'NIT',
                          hintText: '900.123.456-7',
                        ),
                        enabled: !_saving,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _representanteCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Representante legal',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              titulo: 'Recibos',
              descripcion:
                  'El prefijo se usa al numerar los recibos. Por ejemplo si '
                  'configuras "DSQ", los recibos serán "DSQ-2025-00123".',
              children: [
                TextFormField(
                  controller: _prefijoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Prefijo de recibos *',
                    helperText: 'Letras o números cortos. Ej. DSQ',
                    prefixIcon: Icon(Icons.tag),
                  ),
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.characters,
                  validator: _required,
                ),
              ],
            ),
            _Section(
              titulo: 'Cuentas para pago',
              descripcion:
                  'Aparecen al pie del recibo para que el cliente sepa '
                  'a dónde transferir.',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bancolombiaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cuenta Bancolombia',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _nequiCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Número Nequi',
                          prefixIcon: Icon(Icons.smartphone_outlined),
                        ),
                        enabled: !_saving,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              titulo: 'Tarifas por defecto',
              descripcion:
                  'Valores que se sugieren al crear un cliente nuevo. Cada '
                  'cliente puede tener su propia tarifa asignada en su ficha.',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MoneyField(
                        controller: _tarifaBasicaCtrl,
                        label: 'Tarifa básica',
                        required: true,
                        enabled: !_saving,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: MoneyField(
                        controller: _tarifaExtCtrl,
                        label: 'Tarifa extendida',
                        required: true,
                        enabled: !_saving,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              titulo: 'Reglas automáticas de facturación',
              descripcion:
                  'Políticas que el sistema aplica automáticamente al generar '
                  'el recibo. No son tarifas: son reglas de cobro.',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MoneyField(
                        controller: _moraCtrl,
                        label: 'Mora diaria',
                        required: true,
                        helperText: 'Por cada día calendario tras vencimiento',
                        enabled: !_saving,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _diasCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Días hábiles para pago *',
                          helperText: 'Plazo desde la emisión',
                          suffixText: 'días',
                        ),
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _requiredInt,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                MoneyField(
                  controller: _reconexionCtrl,
                  label: 'Costo de reconexión automática',
                  required: true,
                  helperText:
                      'Se cobra solo a clientes suspendidos al volver a su recibo',
                  enabled: !_saving,
                ),
                AppSpacing.gapMd,
                const _ReconexionInfo(),
              ],
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                const Spacer(),
                FilledButton.icon(
                  onPressed: _saving ? null : _guardar,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;

  String? _requiredInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Obligatorio';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Debe ser un número';
    if (n < 0) return 'No puede ser negativo';
    return null;
  }
}

/// Aviso visual que aclara la diferencia entre la "reconexión automática"
/// (regla del sistema, definida acá arriba) y los cargos manuales del
/// catálogo de Conceptos. Es el origen de confusión más común en esta
/// pantalla, así que se muestra inline.
class _ReconexionInfo extends StatelessWidget {
  const _ReconexionInfo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 18,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          AppSpacing.gapSm,
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                children: const [
                  TextSpan(
                    text: 'Reconexión automática vs. manual.\n',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'El valor de arriba se suma automáticamente al recibo '
                        'de un cliente suspendido (por mora o voluntario). Para '
                        'cobrar reconexiones puntuales en otros casos —p. ej. '
                        'un cliente retirado que vuelve, o reconexión por daño— '
                        'crea un concepto en el catálogo y agrégalo desde la '
                        'ficha del cliente como cargo extra.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.titulo,
    required this.children,
    this.descripcion,
  });
  final String titulo;
  final String? descripcion;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (descripcion != null) ...[
              AppSpacing.gapXs,
              Text(
                descripcion!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.gapLg,
            ...children,
          ],
        ),
      ),
    );
  }
}
