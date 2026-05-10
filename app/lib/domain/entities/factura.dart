import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'factura.freezed.dart';
part 'factura.g.dart';

@freezed
class Factura with _$Factura {
  const Factura._();

  const factory Factura({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'cliente_id') required String clienteId,
    required String numero,
    required String periodo,
    @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
    @Default(TipoFactura.mensual)
    TipoFactura tipo,
    @JsonKey(name: 'fecha_emision') required DateTime fechaEmision,
    @JsonKey(name: 'fecha_vencimiento') required DateTime fechaVencimiento,
    @JsonKey(name: 'valor_mensualidad') @Default(0) int valorMensualidad,
    @JsonKey(name: 'valor_mora') @Default(0) int valorMora,
    required int total,
    @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
    @Default(EstadoFactura.pendiente)
    EstadoFactura estado,
    @JsonKey(name: 'motivo_anulacion') String? motivoAnulacion,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Factura;

  factory Factura.fromJson(Map<String, dynamic> json) =>
      _$FacturaFromJson(json);

  bool get esPendiente => estado == EstadoFactura.pendiente;
}

TipoFactura _tipoFromJson(String v) => TipoFactura.fromValue(v);
String _tipoToJson(TipoFactura v) => v.value;
EstadoFactura _estadoFromJson(String v) => EstadoFactura.fromValue(v);
String _estadoToJson(EstadoFactura v) => v.value;
