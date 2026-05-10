import '../../../domain/entities/factura.dart';

/// Resultado del calculo de aplicacion FIFO de un pago a facturas pendientes.
/// No persiste — solo describe que pasaria.
class AplicacionPago {
  AplicacionPago({
    required this.aplicaciones,
    required this.sobrante,
    required this.faltante,
  });

  /// Pares (factura, monto a aplicar). En orden de aplicacion FIFO.
  final List<({Factura factura, int monto})> aplicaciones;

  /// Si el pago excede el saldo, este es el monto sin aplicar (>= 0).
  final int sobrante;

  /// Si el pago es insuficiente, este es lo que falta para cubrir el saldo.
  final int faltante;

  bool get esExacto => sobrante == 0 && faltante == 0;
  bool get cubreTodo => faltante == 0;
  int get totalAplicado => aplicaciones.fold<int>(0, (s, a) => s + a.monto);
}

/// Calcula como se aplicaria un pago a una lista de facturas pendientes.
///
/// Reglas (regla MVP "solo pagos completos"):
/// - FIFO: la factura mas antigua se cierra primero.
/// - Si el pago alcanza el saldo total, todas se cierran.
/// - Si el pago excede el saldo, la diferencia queda como `sobrante`.
/// - Si el pago es menor al saldo, las primeras se cierran y la ultima
///   alcanzada se cubre parcialmente. `faltante` indica cuanto falto.
class AplicacionPagoCalculator {
  const AplicacionPagoCalculator._();

  static AplicacionPago calcular({
    required List<Factura> facturasPendientes,
    required int valorPago,
  }) {
    // Ordenar FIFO por fecha_emision (mas antigua primero) y luego por numero
    // para estabilidad si comparten fecha.
    final ordenadas = [...facturasPendientes]
      ..sort((a, b) {
        final f = a.fechaEmision.compareTo(b.fechaEmision);
        return f != 0 ? f : a.numero.compareTo(b.numero);
      });

    final aplicaciones = <({Factura factura, int monto})>[];
    var restante = valorPago;
    var saldoTotal = 0;

    for (final f in ordenadas) {
      saldoTotal += f.total;
      if (restante <= 0) continue;
      final aAplicar = restante >= f.total ? f.total : restante;
      aplicaciones.add((factura: f, monto: aAplicar));
      restante -= aAplicar;
    }

    final sobrante = restante > 0 ? restante : 0;
    final faltante = saldoTotal - valorPago;
    return AplicacionPago(
      aplicaciones: aplicaciones,
      sobrante: sobrante,
      faltante: faltante > 0 ? faltante : 0,
    );
  }
}
