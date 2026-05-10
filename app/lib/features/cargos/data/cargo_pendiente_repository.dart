import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/cargo_pendiente.dart';
import '../../../domain/entities/perfil.dart';
import '../../auth/presentation/auth_controller.dart';

/// Repositorio de cargos extra (conceptos del catálogo asignados a un
/// cliente, pendientes de aplicar a su próxima factura emitida).
class CargoPendienteRepository {
  CargoPendienteRepository({
    required SupabaseClient client,
    required Perfil perfil,
  }) : _client = client,
       _tenantId = perfil.tenantId,
       _userId = perfil.id;

  final SupabaseClient _client;
  final String _tenantId;
  final String _userId;

  /// Lista los cargos del cliente. Por defecto solo los pendientes
  /// (aún sin aplicar). Pasar `incluirAplicados: true` para mostrar el
  /// histórico (los que ya se cobraron en facturas previas).
  Future<List<CargoPendiente>> listPorCliente(
    String clienteId, {
    bool incluirAplicados = false,
  }) async {
    var query = _client
        .from('cargos_pendientes')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', clienteId);
    if (!incluirAplicados) {
      query = query.filter('aplicado_factura_id', 'is', null);
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List)
        .map((row) => CargoPendiente.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Cargos pendientes de TODOS los clientes (lo usa el BillingService
  /// para el preview masivo).
  Future<List<CargoPendiente>> listPendientesDelTenant() async {
    final data = await _client
        .from('cargos_pendientes')
        .select()
        .eq('tenant_id', _tenantId)
        .filter('aplicado_factura_id', 'is', null)
        .order('created_at');
    return (data as List)
        .map((row) => CargoPendiente.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<CargoPendiente> create({
    required String clienteId,
    required String descripcion,
    required int valorUnitario,
    String? conceptoId,
    int cantidad = 1,
    String? notas,
  }) async {
    final data = await _client
        .from('cargos_pendientes')
        .insert({
          'tenant_id': _tenantId,
          'cliente_id': clienteId,
          'concepto_id': conceptoId,
          'descripcion': descripcion,
          'cantidad': cantidad,
          'valor_unitario': valorUnitario,
          'notas': notas,
          'created_by': _userId,
        })
        .select()
        .single();
    return CargoPendiente.fromJson(data);
  }

  /// Solo permitido por la policy SQL si aún está pendiente.
  Future<void> delete(String id) async {
    await _client
        .from('cargos_pendientes')
        .delete()
        .eq('tenant_id', _tenantId)
        .eq('id', id);
  }
}

final cargoPendienteRepositoryProvider = Provider<CargoPendienteRepository>((
  ref,
) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return CargoPendienteRepository(client: client, perfil: perfil);
});

/// Cargos pendientes de un cliente (los aún no aplicados).
final cargosPendientesPorClienteProvider = FutureProvider.autoDispose
    .family<List<CargoPendiente>, String>((ref, clienteId) async {
      final repo = ref.watch(cargoPendienteRepositoryProvider);
      return repo.listPorCliente(clienteId);
    });

/// Histórico completo de cargos del cliente (incluye aplicados).
final cargosHistoricoPorClienteProvider = FutureProvider.autoDispose
    .family<List<CargoPendiente>, String>((ref, clienteId) async {
      final repo = ref.watch(cargoPendienteRepositoryProvider);
      return repo.listPorCliente(clienteId, incluirAplicados: true);
    });
