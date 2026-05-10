import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/cargo_pendiente.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/enums.dart';

part 'preview_facturacion.freezed.dart';

/// Preview de la factura a emitir para UN cliente, calculada en cliente
/// antes de confirmar la facturacion masiva o individual.
@freezed
class PreviewFacturaCliente with _$PreviewFacturaCliente {
  const PreviewFacturaCliente._();

  const factory PreviewFacturaCliente({
    required Cliente cliente,
    required TipoFactura tipo,

    /// Suma de las facturas anteriores pendientes (mensualidades viejas).
    required int totalAtrasos,

    /// Cantidad de facturas pendientes anteriores.
    required int cantidadAtrasos,

    /// Mensualidad del mes que se esta facturando (0 si suspendido).
    required int valorMensualidad,

    /// Mora a cobrar en esta nueva factura (incremental, no doble).
    required int valorMora,

    /// Costo de reconexion (solo si suspendido).
    required int costoReconexion,

    /// Cargos extra (conceptos) en cola que se aplicarán a esta factura.
    /// Cuando se ejecute la emisión, cada cargo se vuelve una línea de
    /// la factura y se marca como aplicado server-side.
    @Default(<CargoPendiente>[]) List<CargoPendiente> cargosExtras,
  }) = _PreviewFacturaCliente;

  /// Suma de los cargos extras (cantidad × valor cada uno).
  int get totalCargosExtras =>
      cargosExtras.fold<int>(0, (s, c) => s + c.subtotal);

  /// Total que aparece en el recibo del mes (lo que paga el cliente).
  int get totalRecibo =>
      totalAtrasos +
      valorMensualidad +
      valorMora +
      costoReconexion +
      totalCargosExtras;

  /// Total de la NUEVA factura que se va a insertar (sin contar atrasos
  /// que viven en facturas separadas).
  int get totalFacturaNueva =>
      valorMensualidad + valorMora + costoReconexion + totalCargosExtras;

  bool get tieneCargos => totalFacturaNueva > 0;
}
