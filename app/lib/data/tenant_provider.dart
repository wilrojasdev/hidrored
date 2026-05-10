import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/tenant.dart';
import '../features/auth/presentation/auth_controller.dart';
import 'supabase_providers.dart';

/// Carga el tenant del usuario logueado.
final tenantProvider = FutureProvider<Tenant>((ref) async {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('tenants')
      .select()
      .eq('id', perfil.tenantId)
      .single();
  return Tenant.fromJson(data);
});
