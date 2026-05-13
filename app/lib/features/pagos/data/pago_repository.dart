import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/entities/pago_factura.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/aplicacion_pago.dart';

class PagoRepository {
  PagoRepository({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<List<Pago>> list({String? clienteId, int limit = 200}) async {
    var query = _client.from('pagos').select().eq('tenant_id', _tenantId);
    if (clienteId != null) query = query.eq('cliente_id', clienteId);
    final data = await query
        .order('fecha', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);
    final list = (data as List)
        .map((row) => Pago.fromJson(row as Map<String, dynamic>))
        .toList();
    _sortPagosPorFechaRecientePrimero(list);
    return list;
  }

  Future<Pago> get(String id) async {
    final data = await _client
        .from('pagos')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .single();
    return Pago.fromJson(data);
  }

  Future<List<PagoFactura>> aplicacionesDePago(String pagoId) async {
    final data = await _client
        .from('pago_factura')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('pago_id', pagoId);
    return (data as List)
        .map((row) => PagoFactura.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve las facturas pendientes de un cliente, mas antigua primero.
  Future<List<Factura>> facturasPendientesDe(String clienteId) async {
    final data = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', clienteId)
        .eq('estado', EstadoFactura.pendiente.value)
        .order('fecha_emision');
    return (data as List)
        .map((row) => Factura.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Registra un pago y aplica sus montos a las facturas indicadas.
  /// Delegamos al RPC `registrar_pago_completo` para que todo (insert
  /// pago, inserts pago_factura, update facturas, reconexion automatica
  /// si corresponde) ocurra dentro de una sola transaccion server-side.
  Future<Pago> registrarPago({
    required String clienteId,
    required DateTime fecha,
    required int valor,
    required MetodoPago metodo,
    String? referencia,
    String? notas,
    required AplicacionPago aplicacion,
  }) async {
    final aplicacionesJson = [
      for (final a in aplicacion.aplicaciones)
        if (a.monto > 0) {'factura_id': a.factura.id, 'monto': a.monto},
    ];

    final pagoId =
        await _client.rpc(
              'registrar_pago_completo',
              params: {
                'p_cliente_id': clienteId,
                'p_fecha': _toDateOnly(fecha),
                'p_valor': valor,
                'p_metodo': metodo.value,
                'p_referencia': referencia,
                'p_notas': notas,
                'p_aplicaciones': aplicacionesJson,
              },
            )
            as String;

    return get(pagoId);
  }

  static String _toDateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Más reciente primero: `fecha` descendente, luego `created_at` e `id`.
void _sortPagosPorFechaRecientePrimero(List<Pago> pagos) {
  pagos.sort((a, b) {
    final byFecha = b.fecha.compareTo(a.fecha);
    if (byFecha != 0) return byFecha;
    final ca = a.createdAt;
    final cb = b.createdAt;
    if (ca != null && cb != null) {
      final byCreated = cb.compareTo(ca);
      if (byCreated != 0) return byCreated;
    } else if (ca == null && cb != null) {
      return 1;
    } else if (ca != null && cb == null) {
      return -1;
    }
    return b.id.compareTo(a.id);
  });
}

final pagoRepositoryProvider = Provider<PagoRepository>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return PagoRepository(client: client, perfil: perfil);
});
