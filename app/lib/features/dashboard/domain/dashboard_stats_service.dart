import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/clock.dart';
import '../../../data/supabase_providers.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

class DashboardStats {
  DashboardStats({
    required this.clientesPorEstado,
    required this.totalClientes,
    required this.recaudoMes,
    required this.cantidadPagosMes,
    required this.facturasPendientes,
    required this.totalAdeudado,
    required this.danosActivos,
  });

  final Map<EstadoCliente, int> clientesPorEstado;
  final int totalClientes;
  final int recaudoMes;
  final int cantidadPagosMes;
  final int facturasPendientes;
  final int totalAdeudado;
  final int danosActivos;

  int get clientesActivos => clientesPorEstado[EstadoCliente.activo] ?? 0;
  int get clientesSuspendidos =>
      (clientesPorEstado[EstadoCliente.suspendidoMora] ?? 0) +
      (clientesPorEstado[EstadoCliente.suspendidoVoluntario] ?? 0);
}

class DashboardStatsService {
  DashboardStatsService({
    required SupabaseClient client,
    required Perfil perfil,
  }) : _client = client,
       _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<DashboardStats> calcular({DateTime? hoy}) async {
    final ahora = hoy ?? BogotaClock.hoy();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);

    final results = await Future.wait([
      _clientesPorEstado(),
      _pagosDelMes(inicioMes),
      _facturasPendientes(),
      _danosActivos(),
    ]);

    final estadoMap = results[0] as Map<EstadoCliente, int>;
    final pagosMes = results[1] as ({int total, int cantidad});
    final facturas = results[2] as ({int cantidad, int total});
    final danos = results[3] as int;

    final totalClientes = estadoMap.values.fold<int>(0, (s, c) => s + c);

    return DashboardStats(
      clientesPorEstado: estadoMap,
      totalClientes: totalClientes,
      recaudoMes: pagosMes.total,
      cantidadPagosMes: pagosMes.cantidad,
      facturasPendientes: facturas.cantidad,
      totalAdeudado: facturas.total,
      danosActivos: danos,
    );
  }

  Future<Map<EstadoCliente, int>> _clientesPorEstado() async {
    final data = await _client
        .from('clientes')
        .select('estado')
        .eq('tenant_id', _tenantId);
    final map = <EstadoCliente, int>{
      for (final e in EstadoCliente.values) e: 0,
    };
    for (final row in data as List) {
      final estado = EstadoCliente.fromValue(
        (row as Map<String, dynamic>)['estado'] as String,
      );
      map[estado] = (map[estado] ?? 0) + 1;
    }
    return map;
  }

  Future<({int total, int cantidad})> _pagosDelMes(DateTime inicio) async {
    final data = await _client
        .from('pagos')
        .select('valor')
        .eq('tenant_id', _tenantId)
        .gte('fecha', _toDateOnly(inicio));
    final lista = data as List;
    final total = lista.fold<int>(
      0,
      (s, row) => s + ((row as Map<String, dynamic>)['valor'] as int),
    );
    return (total: total, cantidad: lista.length);
  }

  Future<({int cantidad, int total})> _facturasPendientes() async {
    final data = await _client
        .from('facturas')
        .select('total')
        .eq('tenant_id', _tenantId)
        .eq('estado', EstadoFactura.pendiente.value);
    final lista = data as List;
    final total = lista.fold<int>(
      0,
      (s, row) => s + ((row as Map<String, dynamic>)['total'] as int),
    );
    return (cantidad: lista.length, total: total);
  }

  Future<int> _danosActivos() async {
    final data = await _client
        .from('danos')
        .select('id')
        .eq('tenant_id', _tenantId)
        .neq('estado', EstadoDano.solucionado.value);
    return (data as List).length;
  }

  static String _toDateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final dashboardStatsServiceProvider = Provider<DashboardStatsService>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return DashboardStatsService(client: client, perfil: perfil);
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  final service = ref.watch(dashboardStatsServiceProvider);
  return service.calcular();
});
