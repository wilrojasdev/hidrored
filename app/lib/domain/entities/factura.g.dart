// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'factura.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FacturaImpl _$$FacturaImplFromJson(Map<String, dynamic> json) =>
    _$FacturaImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      clienteId: json['cliente_id'] as String,
      numero: json['numero'] as String,
      periodo: json['periodo'] as String,
      tipo: json['tipo'] == null
          ? TipoFactura.mensual
          : _tipoFromJson(json['tipo'] as String),
      fechaEmision: DateTime.parse(json['fecha_emision'] as String),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento'] as String),
      valorMensualidad: (json['valor_mensualidad'] as num?)?.toInt() ?? 0,
      valorMora: (json['valor_mora'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num).toInt(),
      estado: json['estado'] == null
          ? EstadoFactura.pendiente
          : _estadoFromJson(json['estado'] as String),
      motivoAnulacion: json['motivo_anulacion'] as String?,
      refacturadaEnId: json['refacturada_en_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$FacturaImplToJson(_$FacturaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'cliente_id': instance.clienteId,
      'numero': instance.numero,
      'periodo': instance.periodo,
      'tipo': _tipoToJson(instance.tipo),
      'fecha_emision': instance.fechaEmision.toIso8601String(),
      'fecha_vencimiento': instance.fechaVencimiento.toIso8601String(),
      'valor_mensualidad': instance.valorMensualidad,
      'valor_mora': instance.valorMora,
      'total': instance.total,
      'estado': _estadoToJson(instance.estado),
      'motivo_anulacion': instance.motivoAnulacion,
      'refacturada_en_id': instance.refacturadaEnId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
