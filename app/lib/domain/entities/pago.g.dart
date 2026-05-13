// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pago.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PagoImpl _$$PagoImplFromJson(Map<String, dynamic> json) => _$PagoImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      clienteId: json['cliente_id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      valor: (json['valor'] as num).toInt(),
      metodo: _metodoFromJson(json['metodo'] as String),
      referencia: json['referencia'] as String?,
      notas: json['notas'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$PagoImplToJson(_$PagoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'cliente_id': instance.clienteId,
      'fecha': instance.fecha.toIso8601String(),
      'valor': instance.valor,
      'metodo': _metodoToJson(instance.metodo),
      'referencia': instance.referencia,
      'notas': instance.notas,
      'created_at': instance.createdAt?.toIso8601String(),
    };
