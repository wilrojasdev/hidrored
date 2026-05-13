import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_info.dart';
import '../../../core/config/env.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final error = state.error!;
      appLogger.w('Login fallido', error: error, stackTrace: state.stackTrace);
      AppSnackbar.error(context, error);
    }
  }

  Future<void> _onResetPassword() async {
    final email = await _pedirEmailParaReset();
    if (email == null || !mounted) return;
    // Mostrar loader mientras se envía el email.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(email);
      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loader
      AppSnackbar.info(
        context,
        'Si el correo está registrado, recibirás un enlace para crear una '
        'nueva contraseña.',
      );
    } catch (e, stack) {
      appLogger.w('Reset password fallido', error: e, stackTrace: stack);
      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loader
      AppSnackbar.error(context, e);
    }
  }

  Future<String?> _pedirEmailParaReset() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer contraseña'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa tu correo y te enviaremos un enlace para crear una '
                'nueva contraseña.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo';
                  }
                  if (!value.contains('@')) return 'Correo no válido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(ctrl.text.trim());
              }
            },
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isLoading = state.isLoading;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.subtle(context)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Brand(theme: theme),
                    AppSpacing.gapXxl,
                    Card(
                      elevation: 2,
                      shadowColor: theme.colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Iniciar sesión',
                                style: theme.textTheme.titleLarge,
                              ),
                              AppSpacing.gapXs,
                              Text(
                                'Accede al panel del acueducto.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              AppSpacing.gapXl,
                              if (!Env.isConfigured) ...[
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                      ),
                                      AppSpacing.gapSm,
                                      Expanded(
                                        child: Text(
                                          'Backend no configurado. Pasa '
                                          'SUPABASE_URL y SUPABASE_ANON_KEY '
                                          'como --dart-define.',
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onErrorContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppSpacing.gapLg,
                              ],
                              TextFormField(
                                controller: _emailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Correo',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                enabled: !isLoading,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa tu correo';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Correo no válido';
                                  }
                                  return null;
                                },
                              ),
                              AppSpacing.gapMd,
                              TextFormField(
                                controller: _passCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                enabled: !isLoading,
                                onFieldSubmitted: (_) => _onSubmit(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  return null;
                                },
                              ),
                              AppSpacing.gapXl,
                              FilledButton.icon(
                                onPressed: (isLoading || !Env.isConfigured)
                                    ? null
                                    : _onSubmit,
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: Text(
                                  isLoading ? 'Ingresando...' : 'Ingresar',
                                ),
                              ),
                              AppSpacing.gapXs,
                              TextButton(
                                onPressed: (isLoading || !Env.isConfigured)
                                    ? null
                                    : _onResetPassword,
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          kAppDisplayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapXs,
        Text(
          'Gestión de acueductos veredales',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapMd,
        Text(
          kAppVersionLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
