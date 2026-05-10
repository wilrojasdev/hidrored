import '../../domain/enums.dart';
import 'status_chip.dart';

/// Mapea enums del dominio a la variante semántica del [StatusChip].
extension EstadoClienteVariant on EstadoCliente {
  StatusVariant get variant => switch (this) {
    EstadoCliente.activo => StatusVariant.success,
    EstadoCliente.suspendidoMora => StatusVariant.danger,
    EstadoCliente.suspendidoVoluntario => StatusVariant.warning,
    EstadoCliente.danoReportado => StatusVariant.warning,
    EstadoCliente.enReparacion => StatusVariant.info,
    EstadoCliente.retirado => StatusVariant.neutral,
  };
}

extension EstadoFacturaVariant on EstadoFactura {
  StatusVariant get variant => switch (this) {
    EstadoFactura.pendiente => StatusVariant.warning,
    EstadoFactura.pagada => StatusVariant.success,
    EstadoFactura.anulada => StatusVariant.neutral,
  };
}

extension EstadoDanoVariant on EstadoDano {
  StatusVariant get variant => switch (this) {
    EstadoDano.reportado => StatusVariant.warning,
    EstadoDano.enReparacion => StatusVariant.info,
    EstadoDano.solucionado => StatusVariant.success,
  };
}

extension MetodoPagoIcon on MetodoPago {
  /// Pequeño icono diferenciador por método (no confíes solo en color).
  String get emoji => switch (this) {
    MetodoPago.bancolombia => 'BAN',
    MetodoPago.nequi => 'NEQ',
    MetodoPago.efectivo => 'EFE',
    MetodoPago.otro => 'OTR',
  };
}
