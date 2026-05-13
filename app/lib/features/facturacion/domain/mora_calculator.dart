import '../../../domain/entities/factura.dart';

/// Calculo puro de la mora a cobrar al emitir una nueva factura.
///
/// Reglas (modelo "factura unica viva por cliente"):
/// - Cada cliente tiene a lo sumo UNA factura `pendiente` a la vez (la
///   ultima emitida). Esa factura puede contener saldos REFACTURADOS de
///   facturas anteriores (campo `factura_origen_id` en sus lineas).
/// - Para la mora, descomponemos esa factura en "sub-deudas":
///     - Sub-deuda nativa: monto = total - saldos refacturados,
///       fecha_vencimiento = la propia factura, mora_ya_facturada =
///       valor_mora capturado.
///     - Por cada saldo refacturado: fecha_vencimiento = vencimiento
///       ORIGINAL de la factura origen, mora_ya_facturada = 0 (la mora
///       de esa origen ya esta capturada en el `valor_mora` de la
///       factura pendiente actual).
/// - Por cada sub-deuda se cuenta los dias calendario desde el dia
///   siguiente a su vencimiento hasta `hasta`.
/// - Total dias × tarifa_mora_diaria = mora total acumulada.
/// - Se descuenta la mora ya facturada en las facturas pendientes (para
///   evitar doble cobro entre emisiones consecutivas).
///
/// Si NO hay refacturacion previa, el calculo se reduce al mismo
/// comportamiento que el modelo viejo (1 sub-deuda por factura
/// pendiente, todas con su fecha y `valor_mora` propios).
class DeudaParaMora {
  const DeudaParaMora({
    required this.fechaVencimiento,
    required this.moraYaFacturada,
  });

  /// Fecha original a partir de la cual cuenta la mora.
  final DateTime fechaVencimiento;

  /// Mora ya capturada en el `valor_mora` de alguna factura pendiente
  /// del cliente. Solo debe contabilizarse una vez en el conjunto.
  final int moraYaFacturada;
}

class MoraCalculator {
  const MoraCalculator._();

  /// Calcula la mora INCREMENTAL a cobrar en una nueva factura, dada la
  /// lista de sub-deudas pendientes del cliente.
  static int aCobrar({
    required List<DeudaParaMora> deudas,
    required DateTime hasta,
    required int tarifaMoraDiaria,
  }) {
    if (deudas.isEmpty) return 0;

    var diasTotales = 0;
    var moraYaFacturada = 0;
    for (final d in deudas) {
      final inicio = d.fechaVencimiento.add(const Duration(days: 1));
      final dias = hasta.difference(inicio).inDays;
      if (dias > 0) diasTotales += dias;
      moraYaFacturada += d.moraYaFacturada;
    }

    final moraTotal = diasTotales * tarifaMoraDiaria;
    final aCobrar = moraTotal - moraYaFacturada;
    return aCobrar < 0 ? 0 : aCobrar;
  }

  /// Helper para construir las sub-deudas a partir de las facturas
  /// pendientes del cliente y sus origenes refacturadas.
  ///
  /// - [facturasPendientes]: facturas con `estado = pendiente` del
  ///   cliente.
  /// - [saldosRefacturadosPorFactura]: por cada factura pendiente, los
  ///   saldos refacturados que contiene (= filas de `factura_lineas`
  ///   con `factura_origen_id` no nulo, pero solo necesitamos el monto
  ///   y los datos de la factura origen).
  static List<DeudaParaMora> descomponer({
    required List<Factura> facturasPendientes,
    required Map<String, List<SubDeudaRefacturada>>
    saldosRefacturadosPorFactura,
  }) {
    final deudas = <DeudaParaMora>[];
    for (final f in facturasPendientes) {
      final refs = saldosRefacturadosPorFactura[f.id] ?? const [];
      var saldoRefacturadoTotal = 0;
      for (final r in refs) {
        deudas.add(
          DeudaParaMora(
            fechaVencimiento: r.fechaVencimientoOrigen,
            moraYaFacturada: 0,
          ),
        );
        saldoRefacturadoTotal += r.monto;
      }
      // La parte "nativa" de la factura genera otra sub-deuda con su
      // propia fecha de vencimiento. La mora ya facturada se atribuye
      // aqui (al ser la factura "viva", contiene toda la mora capturada).
      final saldoNativo = f.total - saldoRefacturadoTotal;
      if (saldoNativo > 0 || refs.isEmpty) {
        deudas.add(
          DeudaParaMora(
            fechaVencimiento: f.fechaVencimiento,
            moraYaFacturada: f.valorMora,
          ),
        );
      } else {
        // 100% refacturada (sin parte nativa): la mora ya facturada se
        // atribuye a la primera sub-deuda refacturada para no perderla.
        if (deudas.isNotEmpty) {
          final last = deudas.last;
          deudas[deudas.length - 1] = DeudaParaMora(
            fechaVencimiento: last.fechaVencimiento,
            moraYaFacturada: last.moraYaFacturada + f.valorMora,
          );
        }
      }
    }
    return deudas;
  }
}

/// Datos minimos de un saldo refacturado, suficientes para que el
/// calculador de mora arme una sub-deuda. No es la entidad freezed
/// completa; los providers la construyen leyendo `factura_lineas` y la
/// factura origen.
class SubDeudaRefacturada {
  const SubDeudaRefacturada({
    required this.monto,
    required this.fechaVencimientoOrigen,
  });
  final int monto;
  final DateTime fechaVencimientoOrigen;
}
