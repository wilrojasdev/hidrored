import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/clock.dart';
import '../../../data/supabase_providers.dart';
import '../../../data/tenant_provider.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

/// Candidato sugerido para suspension del servicio.
class CandidatoCorte {
  CandidatoCorte({
    required this.cliente,
    required this.facturasPendientes,
    required this.mesesConsecutivosEnMora,
    required this.diasVencidoMasViejo,
    required this.totalAdeudado,
  });

  final Cliente cliente;
  final List<Factura> facturasPendientes;
  final int mesesConsecutivosEnMora;
  final int diasVencidoMasViejo;
  final int totalAdeudado;
}

/// Calcula la sugerencia de "lista de corte" según la regla del MVP:
/// un cliente ACTIVO califica cuando tiene **2 o más meses consecutivos
/// en mora**, contados sobre los `periodo` (YYYY-MM) de sus facturas
/// pendientes y vencidas.
///
/// "Vencida" = `fecha_vencimiento` ya pasó (la fecha de vencimiento ya
/// considera los días hábiles tras emisión, así que basta `ahora` >
/// `fecha_vencimiento`).
///
/// "Consecutivos" = los periodos forman una corrida sin huecos
/// (ej. 2025-03, 2025-04). Dos pendientes vencidas no consecutivas
/// (2025-03 y 2025-05) NO disparan la regla.
class ListaCorteService {
  ListaCorteService({
    required SupabaseClient client,
    required this.tenant,
    required Perfil perfil,
  }) : _client = client,
       _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final Tenant tenant;
  final String _tenantId;

  Future<List<CandidatoCorte>> calcular({DateTime? hoy}) async {
    final ahora = hoy ?? BogotaClock.hoy();

    final clientesData = await _client
        .from('clientes')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('estado', EstadoCliente.activo.value);
    final clientes = (clientesData as List)
        .map((row) => Cliente.fromJson(row as Map<String, dynamic>))
        .toList();

    if (clientes.isEmpty) return [];

    final pendientesData = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('estado', EstadoFactura.pendiente.value)
        .inFilter('cliente_id', clientes.map((s) => s.id).toList());
    final pendientesPorCliente = <String, List<Factura>>{};
    for (final row in pendientesData as List) {
      final f = Factura.fromJson(row as Map<String, dynamic>);
      pendientesPorCliente.putIfAbsent(f.clienteId, () => []).add(f);
    }

    final candidatos = <CandidatoCorte>[];
    for (final s in clientes) {
      final pendientes = pendientesPorCliente[s.id] ?? const [];
      final candidato = evaluarCliente(
        cliente: s,
        pendientes: pendientes,
        ahora: ahora,
      );
      if (candidato != null) candidatos.add(candidato);
    }

    candidatos.sort(
      (a, b) => b.mesesConsecutivosEnMora.compareTo(a.mesesConsecutivosEnMora),
    );
    return candidatos;
  }

  /// Evalúa la regla de corte para un cliente. `null` si NO califica.
  /// Función pura: aislada para poder testearse sin tocar Supabase.
  static CandidatoCorte? evaluarCliente({
    required Cliente cliente,
    required List<Factura> pendientes,
    required DateTime ahora,
  }) {
    if (pendientes.length < 2) return null;

    // Solo facturas que ya pasaron su fecha de vencimiento (estricto).
    final vencidas =
        pendientes.where((f) => ahora.isAfter(f.fechaVencimiento)).toList()
          ..sort((a, b) => a.periodo.compareTo(b.periodo));

    if (vencidas.length < 2) return null;

    // Buscar la corrida más larga de periodos consecutivos.
    var maxCorrida = 1;
    var corridaActual = 1;
    var inicioMaxCorrida = vencidas.first;
    var inicioCorridaActual = vencidas.first;
    for (var i = 1; i < vencidas.length; i++) {
      final prev = _periodoAEntero(vencidas[i - 1].periodo);
      final curr = _periodoAEntero(vencidas[i].periodo);
      if (prev != null && curr != null && curr == prev + 1) {
        corridaActual++;
        if (corridaActual > maxCorrida) {
          maxCorrida = corridaActual;
          inicioMaxCorrida = inicioCorridaActual;
        }
      } else {
        corridaActual = 1;
        inicioCorridaActual = vencidas[i];
      }
    }

    if (maxCorrida < 2) return null;

    // Días vencidos contados desde la primera factura de la corrida.
    final diasVencido = ahora
        .difference(inicioMaxCorrida.fechaVencimiento)
        .inDays;
    final total = pendientes.fold<int>(0, (sum, f) => sum + f.total);

    return CandidatoCorte(
      cliente: cliente,
      facturasPendientes: pendientes,
      mesesConsecutivosEnMora: maxCorrida,
      diasVencidoMasViejo: diasVencido,
      totalAdeudado: total,
    );
  }

  /// Convierte 'YYYY-MM' a un entero comparable (year*12 + month).
  /// Devuelve `null` si el formato es inválido.
  static int? _periodoAEntero(String periodo) {
    final partes = periodo.split('-');
    if (partes.length != 2) return null;
    final year = int.tryParse(partes[0]);
    final month = int.tryParse(partes[1]);
    if (year == null || month == null || month < 1 || month > 12) return null;
    return year * 12 + month;
  }
}

final listaCorteServiceProvider = FutureProvider<ListaCorteService>((
  ref,
) async {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final tenant = await ref.watch(tenantProvider.future);
  final client = ref.watch(supabaseClientProvider);
  return ListaCorteService(client: client, tenant: tenant, perfil: perfil);
});

final listaCorteProvider = FutureProvider.autoDispose<List<CandidatoCorte>>((
  ref,
) async {
  final service = await ref.watch(listaCorteServiceProvider.future);
  return service.calcular();
});
