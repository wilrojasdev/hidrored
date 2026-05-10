import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/factura.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/entities/pago_factura.dart';
import '../data/pago_repository.dart';

final pagosListProvider = FutureProvider.autoDispose<List<Pago>>((ref) async {
  final repo = ref.watch(pagoRepositoryProvider);
  return repo.list();
});

final pagoDetailProvider = FutureProvider.autoDispose.family<Pago, String>((
  ref,
  id,
) async {
  final repo = ref.watch(pagoRepositoryProvider);
  return repo.get(id);
});

final aplicacionesDePagoProvider = FutureProvider.autoDispose
    .family<List<PagoFactura>, String>((ref, pagoId) async {
      final repo = ref.watch(pagoRepositoryProvider);
      return repo.aplicacionesDePago(pagoId);
    });

/// Facturas pendientes (saldo) de un cliente.
final facturasPendientesProvider = FutureProvider.autoDispose
    .family<List<Factura>, String>((ref, clienteId) async {
      final repo = ref.watch(pagoRepositoryProvider);
      return repo.facturasPendientesDe(clienteId);
    });
