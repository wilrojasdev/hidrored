import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/clock.dart';
import '../../../data/supabase_providers.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

/// Ingresos agrupados de un mes especifico, desglosados por metodo de pago.
class IngresosMensuales {
  IngresosMensuales({
    required this.periodo,
    required this.totalPorMetodo,
    required this.cantidadPagos,
  });

  /// Formato YYYY-MM
  final String periodo;
  final Map<MetodoPago, int> totalPorMetodo;
  final int cantidadPagos;

  int get total => totalPorMetodo.values.fold<int>(0, (sum, v) => sum + v);

  int valorDe(MetodoPago m) => totalPorMetodo[m] ?? 0;
}

class IngresosService {
  IngresosService({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  /// Devuelve los ingresos de los ultimos `meses` meses, ordenados de mas
  /// antiguo a mas reciente. Incluye meses sin pagos como series con cero.
  Future<List<IngresosMensuales>> ultimosMeses({int meses = 6}) async {
    final hoy = BogotaClock.hoy();
    final desde = DateTime(hoy.year, hoy.month - meses + 1, 1);

    final data = await _client
        .from('pagos')
        .select()
        .eq('tenant_id', _tenantId)
        .gte('fecha', _toDateOnly(desde))
        .order('fecha');
    final pagos = (data as List)
        .map((row) => Pago.fromJson(row as Map<String, dynamic>))
        .toList();

    // Inicializar mapas vacios para todos los meses del rango.
    final resultados = <String, IngresosMensuales>{};
    for (var i = 0; i < meses; i++) {
      final d = DateTime(desde.year, desde.month + i, 1);
      final periodo = _periodo(d);
      resultados[periodo] = IngresosMensuales(
        periodo: periodo,
        totalPorMetodo: {for (final m in MetodoPago.values) m: 0},
        cantidadPagos: 0,
      );
    }

    // Agregar cada pago al mes correspondiente.
    final acumPorMes = <String, _Acumulador>{
      for (final p in resultados.keys) p: _Acumulador(),
    };
    for (final p in pagos) {
      final periodo = _periodo(p.fecha);
      final acum = acumPorMes[periodo];
      if (acum == null) continue;
      acum.totalPorMetodo[p.metodo] =
          (acum.totalPorMetodo[p.metodo] ?? 0) + p.valor;
      acum.count++;
    }

    return resultados.entries.map((e) {
      final acum = acumPorMes[e.key]!;
      return IngresosMensuales(
        periodo: e.key,
        totalPorMetodo: {
          for (final m in MetodoPago.values) m: acum.totalPorMetodo[m] ?? 0,
        },
        cantidadPagos: acum.count,
      );
    }).toList();
  }

  static String _periodo(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
  static String _toDateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

class _Acumulador {
  final Map<MetodoPago, int> totalPorMetodo = {};
  int count = 0;
}

final ingresosServiceProvider = Provider<IngresosService>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return IngresosService(client: client, perfil: perfil);
});

final ingresosMensualesProvider = FutureProvider.autoDispose
    .family<List<IngresosMensuales>, int>((ref, meses) async {
      final service = ref.watch(ingresosServiceProvider);
      return service.ultimosMeses(meses: meses);
    });
