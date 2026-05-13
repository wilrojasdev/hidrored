// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dano.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DanoImpl _$$DanoImplFromJson(Map<String, dynamic> json) => _$DanoImpl(
  id: json['id'] as String,
  tenantId: json['tenant_id'] as String,
  clienteId: json['cliente_id'] as String,
  fechaReporte: DateTime.parse(json['fecha_reporte'] as String),
  fechaSolucion: json['fecha_solucion'] == null
      ? null
      : DateTime.parse(json['fecha_solucion'] as String),
  descripcion: json['descripcion'] as String,
  costo: (json['costo'] as num?)?.toInt() ?? 0,
  reportadoPor: json['reportado_por'] as String?,
  estado: json['estado'] == null
      ? EstadoDano.reportado
      : _estadoFromJson(json['estado'] as String),
  notas: json['notas'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$DanoImplToJson(_$DanoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'cliente_id': instance.clienteId,
      'fecha_reporte': instance.fechaReporte.toIso8601String(),
      'fecha_solucion': instance.fechaSolucion?.toIso8601String(),
      'descripcion': instance.descripcion,
      'costo': instance.costo,
      'reportado_por': instance.reportadoPor,
      'estado': _estadoToJson(instance.estado),
      'notas': instance.notas,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
