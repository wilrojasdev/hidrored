// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfil.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PerfilImpl _$$PerfilImplFromJson(Map<String, dynamic> json) => _$PerfilImpl(
  id: json['id'] as String,
  tenantId: json['tenant_id'] as String,
  nombre: json['nombre'] as String,
  email: json['email'] as String,
  rol: json['rol'] as String? ?? 'admin',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$PerfilImplToJson(_$PerfilImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'nombre': instance.nombre,
      'email': instance.email,
      'rol': instance.rol,
      'created_at': instance.createdAt?.toIso8601String(),
    };
