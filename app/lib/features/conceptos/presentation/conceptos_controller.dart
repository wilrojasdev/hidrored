import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/concepto.dart';
import '../data/concepto_repository.dart';

final conceptosListProvider = FutureProvider.autoDispose<List<Concepto>>((
  ref,
) async {
  final repo = ref.watch(conceptoRepositoryProvider);
  return repo.list();
});

final conceptoDetailProvider = FutureProvider.autoDispose
    .family<Concepto, String>((ref, id) async {
      final repo = ref.watch(conceptoRepositoryProvider);
      return repo.get(id);
    });
