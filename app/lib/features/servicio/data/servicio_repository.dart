import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/clock.dart';
import '../../../data/supabase_providers.dart';
import '../../../domain/entities/evento_servicio.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

class ServicioRepository {
  ServicioRepository({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  /// Cambia el estado de un cliente y agrega un evento a la bitacora.
  /// Si el cambio implica retiro, marca fecha_retiro tambien.
  Future<void> cambiarEstado({
    required String clienteId,
    required EstadoCliente nuevoEstado,
    required TipoEventoServicio tipoEvento,
    String? motivo,
    int? costo,
  }) async {
    final patch = <String, dynamic>{'estado': nuevoEstado.value};
    if (nuevoEstado == EstadoCliente.retirado) {
      patch['fecha_retiro'] = BogotaClock.hoyIso();
    }

    await _client
        .from('clientes')
        .update(patch)
        .eq('tenant_id', _tenantId)
        .eq('id', clienteId);

    await _client.from('eventos_servicio').insert({
      'tenant_id': _tenantId,
      'cliente_id': clienteId,
      'tipo': tipoEvento.value,
      'estado_resultante': nuevoEstado.value,
      'motivo': motivo,
      'costo': costo,
    });
  }

  /// Suspende por mora a un cliente (atajo).
  Future<void> suspenderPorMora(String clienteId, {String? motivo}) =>
      cambiarEstado(
        clienteId: clienteId,
        nuevoEstado: EstadoCliente.suspendidoMora,
        tipoEvento: TipoEventoServicio.suspension,
        motivo: motivo ?? 'Suspendido por mora',
      );

  /// Reconecta un cliente (vuelve a activo).
  Future<void> reconectar(String clienteId, {String? motivo, int? costo}) =>
      cambiarEstado(
        clienteId: clienteId,
        nuevoEstado: EstadoCliente.activo,
        tipoEvento: TipoEventoServicio.reconexion,
        motivo: motivo,
        costo: costo,
      );

  /// Eventos del cliente, mas reciente primero.
  Future<List<EventoServicio>> bitacoraDe(String clienteId) async {
    final data = await _client
        .from('eventos_servicio')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', clienteId)
        .order('fecha', ascending: false);
    return (data as List)
        .map((row) => EventoServicio.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Eventos recientes de TODO el tenant.
  Future<List<EventoServicio>> eventosRecientes({int limit = 100}) async {
    final data = await _client
        .from('eventos_servicio')
        .select()
        .eq('tenant_id', _tenantId)
        .order('fecha', ascending: false)
        .limit(limit);
    return (data as List)
        .map((row) => EventoServicio.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

final servicioRepositoryProvider = Provider<ServicioRepository>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return ServicioRepository(client: client, perfil: perfil);
});
