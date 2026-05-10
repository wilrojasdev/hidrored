import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../data/tenant_provider.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/factura_linea.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/recibo_data.dart';

/// Carga la informacion necesaria para imprimir uno o mas recibos.
class ReciboDataLoader {
  ReciboDataLoader({
    required SupabaseClient client,
    required this.tenant,
    required Perfil perfil,
  }) : _client = client,
       _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final Tenant tenant;
  final String _tenantId;

  Future<ReciboData> cargarUno(Factura factura) async {
    final results = await Future.wait([
      _cliente(factura.clienteId),
      _lineas(factura.id),
      _pendientesAnteriores(factura),
    ]);
    return ReciboData(
      tenant: tenant,
      cliente: results[0] as Cliente,
      factura: factura,
      lineas: results[1] as List<FacturaLinea>,
      facturasAnteriores: results[2] as List<Factura>,
    );
  }

  /// Carga datos para varias facturas (lote del mes). Optimiza pre-cargando
  /// todos los clientes y todas las pendientes.
  Future<List<ReciboData>> cargarLote(List<Factura> facturas) async {
    if (facturas.isEmpty) return [];

    // Clientes de las facturas.
    final clienteIds = facturas.map((f) => f.clienteId).toSet().toList();
    final clientesData = await _client
        .from('clientes')
        .select()
        .eq('tenant_id', _tenantId)
        .inFilter('id', clienteIds);
    final clientesMap = {
      for (final row in clientesData as List)
        (row as Map<String, dynamic>)['id'] as String: Cliente.fromJson(row),
    };

    // Todas las pendientes de esos clientes (incluyendo las del lote).
    final pendientesData = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('estado', EstadoFactura.pendiente.value)
        .inFilter('cliente_id', clienteIds);
    final pendientesPorCliente = <String, List<Factura>>{};
    for (final row in pendientesData as List) {
      final f = Factura.fromJson(row as Map<String, dynamic>);
      pendientesPorCliente.putIfAbsent(f.clienteId, () => []).add(f);
    }

    // Todas las lineas de las facturas del lote.
    final facturaIds = facturas.map((f) => f.id).toList();
    final lineasData = await _client
        .from('factura_lineas')
        .select()
        .eq('tenant_id', _tenantId)
        .inFilter('factura_id', facturaIds);
    final lineasPorFactura = <String, List<FacturaLinea>>{};
    for (final row in lineasData as List) {
      final l = FacturaLinea.fromJson(row as Map<String, dynamic>);
      lineasPorFactura.putIfAbsent(l.facturaId, () => []).add(l);
    }

    return facturas.map((f) {
      final pendientes = pendientesPorCliente[f.clienteId] ?? const [];
      // Excluir la factura misma de "atrasadas".
      final anteriores = pendientes.where((p) => p.id != f.id).toList();
      return ReciboData(
        tenant: tenant,
        cliente: clientesMap[f.clienteId]!,
        factura: f,
        lineas: lineasPorFactura[f.id] ?? const [],
        facturasAnteriores: anteriores,
      );
    }).toList();
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

  Future<List<FacturaLinea>> _lineas(String facturaId) async {
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

  Future<List<Factura>> _pendientesAnteriores(Factura actual) async {
    final data = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', actual.clienteId)
        .eq('estado', EstadoFactura.pendiente.value)
        .neq('id', actual.id)
        .order('fecha_emision');
    return (data as List)
        .map((row) => Factura.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

final reciboDataLoaderProvider = FutureProvider<ReciboDataLoader>((ref) async {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final tenant = await ref.watch(tenantProvider.future);
  final client = ref.watch(supabaseClientProvider);
  return ReciboDataLoader(client: client, tenant: tenant, perfil: perfil);
});
