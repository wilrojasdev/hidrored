// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClienteImpl _$$ClienteImplFromJson(Map<String, dynamic> json) =>
    _$ClienteImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      codigo: (json['codigo'] as num).toInt(),
      cedula: json['cedula'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      telefono: json['telefono'] as String?,
      sector: json['sector'] as String?,
      zona: json['zona'] as String?,
      barrio: json['barrio'] as String?,
      tarifaMensual: (json['tarifa_mensual'] as num).toInt(),
      estado: json['estado'] == null
          ? EstadoCliente.activo
          : _estadoFromJson(json['estado'] as String),
      fechaIngreso: DateTime.parse(json['fecha_ingreso'] as String),
      fechaRetiro: json['fecha_retiro'] == null
          ? null
          : DateTime.parse(json['fecha_retiro'] as String),
      deudaInicial: (json['deuda_inicial'] as num?)?.toInt() ?? 0,
      notas: json['notas'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ClienteImplToJson(_$ClienteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'codigo': instance.codigo,
      'cedula': instance.cedula,
      'nombre': instance.nombre,
      'direccion': instance.direccion,
      'telefono': instance.telefono,
      'sector': instance.sector,
      'zona': instance.zona,
      'barrio': instance.barrio,
      'tarifa_mensual': instance.tarifaMensual,
      'estado': _estadoToJson(instance.estado),
      'fecha_ingreso': instance.fechaIngreso.toIso8601String(),
      'fecha_retiro': instance.fechaRetiro?.toIso8601String(),
      'deuda_inicial': instance.deudaInicial,
      'notas': instance.notas,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
