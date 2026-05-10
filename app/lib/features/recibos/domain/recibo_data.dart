import '../../../domain/entities/factura.dart';
import '../../../domain/entities/factura_linea.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/tenant.dart';

/// Datos completos para imprimir/compartir un recibo de un cliente.
class ReciboData {
  ReciboData({
    required this.tenant,
    required this.cliente,
    required this.factura,
    required this.lineas,
    required this.facturasAnteriores,
  });

  final Tenant tenant;
  final Cliente cliente;
  final Factura factura;
  final List<FacturaLinea> lineas;

  /// Facturas pendientes ANTERIORES (no incluye la `factura` actual).
  final List<Factura> facturasAnteriores;

  int get totalAtrasos =>
      facturasAnteriores.fold<int>(0, (s, f) => s + f.total);

  int get cantidadAtrasos => facturasAnteriores.length;

  /// Total que el cliente debe pagar al recibir este recibo.
  int get totalReciboCobrar => totalAtrasos + factura.total;
}
