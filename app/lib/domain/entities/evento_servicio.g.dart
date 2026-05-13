// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evento_servicio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventoServicioImpl _$$EventoServicioImplFromJson(Map<String, dynamic> json) =>
    _$EventoServicioImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      clienteId: json['cliente_id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: _tipoFromJson(json['tipo'] as String),
      estadoResultante: json['estado_resultante'] as String?,
      motivo: json['motivo'] as String?,
      costo: (json['costo'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$EventoServicioImplToJson(
        _$EventoServicioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'cliente_id': instance.clienteId,
      'fecha': instance.fecha.toIso8601String(),
      'tipo': _tipoToJson(instance.tipo),
      'estado_resultante': instance.estadoResultante,
      'motivo': instance.motivo,
      'costo': instance.costo,
      'created_at': instance.createdAt?.toIso8601String(),
    };
