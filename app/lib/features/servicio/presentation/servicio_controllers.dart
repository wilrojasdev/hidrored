import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/dano.dart';
import '../../../domain/entities/evento_servicio.dart';
import '../data/dano_repository.dart';
import '../data/servicio_repository.dart';

final danosListProvider = FutureProvider.autoDispose<List<Dano>>((ref) async {
  final repo = ref.watch(danoRepositoryProvider);
  return repo.list();
});

final danoDetailProvider = FutureProvider.autoDispose.family<Dano, String>((
  ref,
  id,
) async {
  final repo = ref.watch(danoRepositoryProvider);
  return repo.get(id);
});

final eventosRecientesProvider =
    FutureProvider.autoDispose<List<EventoServicio>>((ref) async {
      final repo = ref.watch(servicioRepositoryProvider);
      return repo.eventosRecientes();
    });

final bitacoraClienteProvider = FutureProvider.autoDispose
    .family<List<EventoServicio>, String>((ref, clienteId) async {
      final repo = ref.watch(servicioRepositoryProvider);
      return repo.bitacoraDe(clienteId);
    });
