import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/clock.dart';
import '../../../data/supabase_providers.dart';
import '../../../data/tenant_provider.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/tenant.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/estado_cuenta_data.dart';

class EstadoCuentaLoader {
  EstadoCuentaLoader({
    required SupabaseClient client,
    required this.tenant,
    required Perfil perfil,
  }) : _client = client,
       _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final Tenant tenant;
  final String _tenantId;

  Future<EstadoCuentaData> cargar(String clienteId) async {
    final results = await Future.wait([
      _cliente(clienteId),
      _facturas(clienteId),
      _pagos(clienteId),
    ]);
    return EstadoCuentaData(
      tenant: tenant,
      cliente: results[0] as Cliente,
      facturas: results[1] as List<Factura>,
      pagos: results[2] as List<Pago>,
      fechaCorte: BogotaClock.hoy(),
    );
  }

  Future<Cliente> _cliente(String id) async {
    final data = await _client
        .from('clientes')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .single();
    return Cliente.fromJson(data);
  }

  Future<List<Factura>> _facturas(String clienteId) async {
    final data = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', clienteId)
        .order('fecha_emision');
    return (data as List)
        .map((row) => Factura.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Pago>> _pagos(String clienteId) async {
    final data = await _client
        .from('pagos')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', clienteId)
        .order('fecha', ascending: true)
        .order('created_at', ascending: true);
    return (data as List)
        .map((row) => Pago.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

final estadoCuentaLoaderProvider = FutureProvider<EstadoCuentaLoader>((
  ref,
) async {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final tenant = await ref.watch(tenantProvider.future);
  final client = ref.watch(supabaseClientProvider);
  return EstadoCuentaLoader(client: client, tenant: tenant, perfil: perfil);
});
