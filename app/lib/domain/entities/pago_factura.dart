import 'package:freezed_annotation/freezed_annotation.dart';

part 'pago_factura.freezed.dart';
part 'pago_factura.g.dart';

@freezed
class PagoFactura with _$PagoFactura {
  const factory PagoFactura({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'pago_id') required String pagoId,
    @JsonKey(name: 'factura_id') required String facturaId,
    @JsonKey(name: 'monto_aplicado') required int montoAplicado,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PagoFactura;

  factory PagoFactura.fromJson(Map<String, dynamic> json) =>
      _$PagoFacturaFromJson(json);
}
