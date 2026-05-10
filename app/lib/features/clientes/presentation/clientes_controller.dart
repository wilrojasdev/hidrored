import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/cliente.dart';
import '../data/cliente_repository.dart';

/// Termino de busqueda actual (nombre, cedula, direccion).
final clientesSearchProvider = StateProvider<String>((ref) => '');

/// Listado de clientes filtrado por el termino de busqueda.
final clientesListProvider = FutureProvider.autoDispose<List<Cliente>>((
  ref,
) async {
  final search = ref.watch(clientesSearchProvider);
  final repo = ref.watch(clienteRepositoryProvider);
  return repo.list(search: search);
});

/// Detalle de un cliente.
final clienteDetailProvider = FutureProvider.autoDispose
    .family<Cliente, String>((ref, id) async {
      final repo = ref.watch(clienteRepositoryProvider);
      return repo.get(id);
    });

/// Siguiente codigo consecutivo para creacion.
final nextCodigoProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(clienteRepositoryProvider);
  return repo.nextCodigo();
});
