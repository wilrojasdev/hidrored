import 'package:freezed_annotation/freezed_annotation.dart';

part 'factura_linea.freezed.dart';
part 'factura_linea.g.dart';

@freezed
class FacturaLinea with _$FacturaLinea {
  const factory FacturaLinea({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'factura_id') required String facturaId,
    @JsonKey(name: 'concepto_id') String? conceptoId,
    required String descripcion,
    @Default(1) int cantidad,
    @JsonKey(name: 'valor_unitario') required int valorUnitario,
    required int subtotal,
    @JsonKey(name: 'factura_origen_id') String? facturaOrigenId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _FacturaLinea;

  factory FacturaLinea.fromJson(Map<String, dynamic> json) =>
      _$FacturaLineaFromJson(json);
}
