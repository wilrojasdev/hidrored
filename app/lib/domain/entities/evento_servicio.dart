import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'evento_servicio.freezed.dart';
part 'evento_servicio.g.dart';

@freezed
class EventoServicio with _$EventoServicio {
  const factory EventoServicio({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'cliente_id') required String clienteId,
    required DateTime fecha,
    @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
    required TipoEventoServicio tipo,
    @JsonKey(name: 'estado_resultante') String? estadoResultante,
    String? motivo,
    int? costo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _EventoServicio;

  factory EventoServicio.fromJson(Map<String, dynamic> json) =>
      _$EventoServicioFromJson(json);
}

TipoEventoServicio _tipoFromJson(String v) => TipoEventoServicio.fromValue(v);
String _tipoToJson(TipoEventoServicio v) => v.value;
