// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concepto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConceptoImpl _$$ConceptoImplFromJson(Map<String, dynamic> json) =>
    _$ConceptoImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      nombre: json['nombre'] as String,
      valorDefault: (json['valor_default'] as num?)?.toInt() ?? 0,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ConceptoImplToJson(_$ConceptoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'nombre': instance.nombre,
      'valor_default': instance.valorDefault,
      'descripcion': instance.descripcion,
      'activo': instance.activo,
      'created_at': instance.createdAt?.toIso8601String(),
    };
