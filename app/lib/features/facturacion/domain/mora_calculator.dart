import '../../../domain/entities/factura.dart';

/// Calculo puro de la mora a cobrar al emitir una nueva factura.
///
/// Reglas (segun decisiones del cliente):
/// - Por cada factura pendiente, se cuentan los dias calendario desde el
///   dia siguiente a su vencimiento hasta `hasta`.
/// - Total de dias x tarifa_mora_diaria = mora total acumulada.
/// - Para evitar doble cobro, se descuenta la mora ya capturada en
///   facturas pendientes anteriores (campo `valor_mora` de cada una).
///
/// **Limitacion conocida (MVP)**: la mora se calcula contra la lista de
/// facturas que estan PENDIENTES en el momento del calculo. Si el admin
/// registra un pago con fecha retroactiva (ej. el cliente pago el 1 del
/// mes pero el admin lo registra el 8), la factura del mes anterior ya
/// puede haber cobrado mora hasta el 30 (cuando se emitio), incluyendo
/// dias en los que el cliente ya habia pagado. Esa diferencia (~5-7
/// dias) NO se reembolsa automaticamente.
///
/// Mitigacion operativa: pedir al admin registrar pagos el mismo dia o
/// al dia siguiente. Si el problema se vuelve recurrente, una version
/// futura puede aceptar `pagos` como parametro adicional y cortar el
/// conteo de mora a la fecha real del primer pago aplicado.
class MoraCalculator {
  const MoraCalculator._();

  /// Calcula la mora INCREMENTAL a cobrar en una nueva factura.
  static int aCobrar({
    required List<Factura> facturasPendientes,
    required DateTime hasta,
    required int tarifaMoraDiaria,
  }) {
    if (facturasPendientes.isEmpty) return 0;

    var diasTotales = 0;
    var moraYaFacturada = 0;
    for (final f in facturasPendientes) {
      final inicio = f.fechaVencimiento.add(const Duration(days: 1));
      final dias = hasta.difference(inicio).inDays;
      if (dias > 0) diasTotales += dias;
      moraYaFacturada += f.valorMora;
    }

    final moraTotal = diasTotales * tarifaMoraDiaria;
    final aCobrar = moraTotal - moraYaFacturada;
    return aCobrar < 0 ? 0 : aCobrar;
  }
}
