import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'dano.freezed.dart';
part 'dano.g.dart';

@freezed
class Dano with _$Dano {
  const factory Dano({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'cliente_id') required String clienteId,
    @JsonKey(name: 'fecha_reporte') required DateTime fechaReporte,
    @JsonKey(name: 'fecha_solucion') DateTime? fechaSolucion,
    required String descripcion,
    @Default(0) int costo,
    @JsonKey(name: 'reportado_por') String? reportadoPor,
    @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
    @Default(EstadoDano.reportado)
    EstadoDano estado,
    String? notas,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Dano;

  factory Dano.fromJson(Map<String, dynamic> json) => _$DanoFromJson(json);
}

EstadoDano _estadoFromJson(String v) => EstadoDano.fromValue(v);
String _estadoToJson(EstadoDano v) => v.value;
