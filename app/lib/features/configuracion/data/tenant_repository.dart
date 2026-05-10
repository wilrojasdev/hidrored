import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/tenant.dart';
import '../../auth/presentation/auth_controller.dart';

class TenantRepository {
  TenantRepository({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<Tenant> update({
    String? nombre,
    String? nit,
    String? representanteLegal,
    String? prefijoRecibos,
    String? cuentaBancolombia,
    String? cuentaNequi,
    int? tarifaMoraDiaria,
    int? costoReconexion,
    int? tarifaBasica,
    int? tarifaExtendida,
    int? diasHabilesPago,
  }) async {
    final patch = <String, dynamic>{
      if (nombre != null) 'nombre': nombre,
      'nit': nit,
      'representante_legal': representanteLegal,
      if (prefijoRecibos != null) 'prefijo_recibos': prefijoRecibos,
      'cuenta_bancolombia': cuentaBancolombia,
      'cuenta_nequi': cuentaNequi,
      if (tarifaMoraDiaria != null) 'tarifa_mora_diaria': tarifaMoraDiaria,
      if (costoReconexion != null) 'costo_reconexion': costoReconexion,
      if (tarifaBasica != null) 'tarifa_basica': tarifaBasica,
      if (tarifaExtendida != null) 'tarifa_extendida': tarifaExtendida,
      if (diasHabilesPago != null) 'dias_habiles_pago': diasHabilesPago,
    };
    final data = await _client
        .from('tenants')
        .update(patch)
        .eq('id', _tenantId)
        .select()
        .single();
    return Tenant.fromJson(data);
  }
}

final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return TenantRepository(client: client, perfil: perfil);
});
