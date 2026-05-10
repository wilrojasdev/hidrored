import '../../../domain/entities/factura.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/tenant.dart';

/// Datos completos para imprimir el estado de cuenta de un cliente.
class EstadoCuentaData {
  EstadoCuentaData({
    required this.tenant,
    required this.cliente,
    required this.facturas,
    required this.pagos,
    required this.fechaCorte,
  });

  final Tenant tenant;
  final Cliente cliente;

  /// Todas las facturas (pendientes, pagadas, anuladas) ordenadas por
  /// fecha de emision (mas antigua primero).
  final List<Factura> facturas;

  /// Todos los pagos del cliente ordenados por fecha (mas antiguo primero).
  final List<Pago> pagos;

  final DateTime fechaCorte;
}
