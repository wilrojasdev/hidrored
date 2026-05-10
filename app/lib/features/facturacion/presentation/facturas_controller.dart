import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/factura.dart';
import '../../../domain/entities/factura_linea.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/enums.dart';
import '../../clientes/data/cliente_repository.dart';
import '../data/factura_repository.dart';

/// Filtros activos en la lista de facturas.
class FacturasFiltro {
  const FacturasFiltro({this.periodo, this.estado, this.clienteId});
  final String? periodo;
  final EstadoFactura? estado;
  final String? clienteId;

  FacturasFiltro copyWith({
    Object? periodo = _sentinel,
    Object? estado = _sentinel,
    Object? clienteId = _sentinel,
  }) {
    return FacturasFiltro(
      periodo: periodo == _sentinel ? this.periodo : periodo as String?,
      estado: estado == _sentinel ? this.estado : estado as EstadoFactura?,
      clienteId: clienteId == _sentinel ? this.clienteId : clienteId as String?,
    );
  }
}

const _sentinel = Object();

final facturasFiltroProvider = StateProvider<FacturasFiltro>(
  (ref) => const FacturasFiltro(),
);

final facturasListProvider = FutureProvider.autoDispose<List<Factura>>((
  ref,
) async {
  final filtro = ref.watch(facturasFiltroProvider);
  final repo = ref.watch(facturaRepositoryProvider);
  return repo.list(
    periodo: filtro.periodo,
    estado: filtro.estado,
    clienteId: filtro.clienteId,
  );
});

final periodosExistentesProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final repo = ref.watch(facturaRepositoryProvider);
  return repo.periodosExistentes();
});

final facturaDetailProvider = FutureProvider.autoDispose
    .family<Factura, String>((ref, id) async {
      final repo = ref.watch(facturaRepositoryProvider);
      return repo.get(id);
    });

final facturaLineasProvider = FutureProvider.autoDispose
    .family<List<FacturaLinea>, String>((ref, facturaId) async {
      final repo = ref.watch(facturaRepositoryProvider);
      return repo.getLineas(facturaId);
    });

/// Mapa de id -> Cliente, para resolver nombres rapido en la lista.
final clientesMapProvider = FutureProvider.autoDispose<Map<String, Cliente>>((
  ref,
) async {
  final repo = ref.watch(clienteRepositoryProvider);
  final list = await repo.list();
  return {for (final s in list) s.id: s};
});
