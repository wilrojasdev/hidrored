import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/cargo_pendiente.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/enums.dart';

part 'preview_facturacion.freezed.dart';

/// Preview de la factura a emitir para UN cliente, calculada en cliente
/// antes de confirmar la facturacion masiva o individual.
///
/// Modelo "factura unica viva por cliente": las facturas pendientes
/// anteriores se absorben en la nueva como [lineasRefacturadas]. El total
/// del recibo es UNO solo (mensualidad + mora + reconexion + extras +
/// saldos refacturados).
@freezed
class PreviewFacturaCliente with _$PreviewFacturaCliente {
  const PreviewFacturaCliente._();

  const factory PreviewFacturaCliente({
    required Cliente cliente,
    required TipoFactura tipo,

    /// Mensualidad del mes que se esta facturando (0 si suspendido).
    required int valorMensualidad,

    /// Mora total a cobrar en esta nueva factura. Calculada como mora
    /// sobre TODAS las sub-deudas pendientes (cada saldo refacturado
    /// arrastra los dias desde su vencimiento ORIGINAL), descontando lo
    /// ya capturado en facturas anteriores.
    required int valorMora,

    /// Costo de reconexion (solo si suspendido).
    required int costoReconexion,

    /// Cargos extra (conceptos) en cola que se aplicaran como linea de la
    /// factura. Cuando se emita, cada uno queda marcado como aplicado.
    @Default(<CargoPendiente>[]) List<CargoPendiente> cargosExtras,

    /// Saldos pendientes anteriores que seran absorbidos en esta factura.
    /// Cada uno se inserta server-side como una linea con
    /// `factura_origen_id` apuntando a su factura origen.
    @Default(<SaldoRefacturado>[]) List<SaldoRefacturado> lineasRefacturadas,
  }) = _PreviewFacturaCliente;

  /// Suma de los cargos extras (cantidad x valor cada uno).
  int get totalCargosExtras =>
      cargosExtras.fold<int>(0, (s, c) => s + c.subtotal);

  /// Suma de saldos refacturados a absorber.
  int get totalRefacturado =>
      lineasRefacturadas.fold<int>(0, (s, l) => s + l.saldo);

  /// Cantidad de facturas anteriores absorbidas.
  int get cantidadRefacturadas => lineasRefacturadas.length;

  /// Total que se va a cobrar en este recibo (igual al total que se
  /// inserta en `facturas.total`).
  int get totalRecibo =>
      valorMensualidad +
      valorMora +
      costoReconexion +
      totalCargosExtras +
      totalRefacturado;

  /// Compatibilidad con codigo previo: hoy `totalFacturaNueva` ==
  /// `totalRecibo` porque ya no hay distincion entre "atrasos" y "nuevo".
  int get totalFacturaNueva => totalRecibo;

  /// Hay algo a emitir? (mensualidad, mora, extras o saldo absorbido)
  bool get tieneCargos => totalRecibo > 0;
}

/// Datos de un saldo pendiente anterior que sera absorbido como linea
/// de la nueva factura.
@freezed
class SaldoRefacturado with _$SaldoRefacturado {
  const factory SaldoRefacturado({
    required String facturaOrigenId,
    required String numero,
    required String periodo,
    required DateTime fechaVencimiento,

    /// Mora ya facturada en la factura origen (capturada al emitirla).
    /// Sirve para evitar doble cobro al recalcular mora.
    required int moraYaFacturadaEnOrigen,

    /// Saldo no pagado: total - sum(pago_factura.monto_aplicado).
    required int saldo,
  }) = _SaldoRefacturado;
}
