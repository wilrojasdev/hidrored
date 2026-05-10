import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/clock.dart';
import '../../../data/supabase_providers.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

/// Cliente moroso con sus metricas asociadas.
class Moroso {
  Moroso({
    required this.cliente,
    required this.cantidadFacturas,
    required this.totalAdeudado,
    required this.diasMaxVencido,
  });

  final Cliente cliente;
  final int cantidadFacturas;
  final int totalAdeudado;
  final int diasMaxVencido;
}

/// Calcula la lista de morosos: clientes con saldo > 0.
class MorososService {
  MorososService({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<List<Moroso>> calcular({DateTime? hoy}) async {
    final ahora = hoy ?? BogotaClock.hoy();

    // Clientes no retirados.
    final susData = await _client
        .from('clientes')
        .select()
        .eq('tenant_id', _tenantId)
        .neq('estado', EstadoCliente.retirado.value);
    final clientes = (susData as List)
        .map((row) => Cliente.fromJson(row as Map<String, dynamic>))
        .toList();
    if (clientes.isEmpty) return [];

    final facturasData = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('estado', EstadoFactura.pendiente.value)
        .inFilter('cliente_id', clientes.map((s) => s.id).toList());
    final pendientesPorCliente = <String, List<Factura>>{};
    for (final row in facturasData as List) {
      final f = Factura.fromJson(row as Map<String, dynamic>);
      pendientesPorCliente.putIfAbsent(f.clienteId, () => []).add(f);
    }

    final morosos = <Moroso>[];
    for (final s in clientes) {
      final pendientes = pendientesPorCliente[s.id] ?? const [];
      if (pendientes.isEmpty) continue;

      final total = pendientes.fold<int>(0, (sum, f) => sum + f.total);
      final masVieja = pendientes
          .map((f) => f.fechaVencimiento)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final dias = ahora.difference(masVieja).inDays;

      morosos.add(
        Moroso(
          cliente: s,
          cantidadFacturas: pendientes.length,
          totalAdeudado: total,
          diasMaxVencido: dias < 0 ? 0 : dias,
        ),
      );
    }

    morosos.sort((a, b) => b.totalAdeudado.compareTo(a.totalAdeudado));
    return morosos;
  }
}

final morososServiceProvider = Provider<MorososService>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return MorososService(client: client, perfil: perfil);
});

final morososProvider = FutureProvider.autoDispose<List<Moroso>>((ref) async {
  final service = ref.watch(morososServiceProvider);
  return service.calcular();
});
