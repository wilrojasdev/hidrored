import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'pago.freezed.dart';
part 'pago.g.dart';

@freezed
class Pago with _$Pago {
  const factory Pago({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'cliente_id') required String clienteId,
    required DateTime fecha,
    required int valor,
    @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
    required MetodoPago metodo,
    String? referencia,
    String? notas,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Pago;

  factory Pago.fromJson(Map<String, dynamic> json) => _$PagoFromJson(json);
}

MetodoPago _metodoFromJson(String v) => MetodoPago.fromValue(v);
String _metodoToJson(MetodoPago v) => v.value;
