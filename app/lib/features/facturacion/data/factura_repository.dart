import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/factura_linea.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

class FacturaRepository {
  FacturaRepository({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<List<Factura>> list({
    String? periodo,
    EstadoFactura? estado,
    String? clienteId,
  }) async {
    var query = _client.from('facturas').select().eq('tenant_id', _tenantId);
    if (periodo != null) query = query.eq('periodo', periodo);
    if (estado != null) query = query.eq('estado', estado.value);
    if (clienteId != null) query = query.eq('cliente_id', clienteId);
    final data = await query.order('fecha_emision', ascending: false);
    return (data as List)
        .map((row) => Factura.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Factura> get(String id) async {
    final data = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .single();
    return Factura.fromJson(data);
  }

  Future<List<FacturaLinea>> getLineas(String facturaId) async {
    final data = await _client
        .from('factura_lineas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('factura_id', facturaId)
        .order('created_at');
    return (data as List)
        .map((row) => FacturaLinea.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene los periodos distintos para los que existen facturas.
  Future<List<String>> periodosExistentes() async {
    final data = await _client
        .from('facturas')
        .select('periodo')
        .eq('tenant_id', _tenantId);
    final set = <String>{};
    for (final row in data as List) {
      set.add((row as Map<String, dynamic>)['periodo'] as String);
    }
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  /// Anula la factura vía RPC `anular_factura`. El RPC, además de cambiar
  /// el estado, revierte cualquier cargo pendiente que se hubiera
  /// aplicado a esta factura para que reaparezca en la re-emisión.
  Future<void> anular(String id, {required String motivo}) async {
    await _client.rpc(
      'anular_factura',
      params: {'p_factura_id': id, 'p_motivo': motivo},
    );
  }

  /// Cantidad de facturas pendientes de un cliente.
  Future<int> cantidadPendientes(String clienteId) async {
    final data = await _client
        .from('facturas')
        .select('id')
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', clienteId)
        .eq('estado', EstadoFactura.pendiente.value);
    return (data as List).length;
  }
}

final facturaRepositoryProvider = Provider<FacturaRepository>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return FacturaRepository(client: client, perfil: perfil);
});
