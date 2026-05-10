// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'factura_linea.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FacturaLineaImpl _$$FacturaLineaImplFromJson(Map<String, dynamic> json) =>
    _$FacturaLineaImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      facturaId: json['factura_id'] as String,
      conceptoId: json['concepto_id'] as String?,
      descripcion: json['descripcion'] as String,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
      valorUnitario: (json['valor_unitario'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$FacturaLineaImplToJson(_$FacturaLineaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'factura_id': instance.facturaId,
      'concepto_id': instance.conceptoId,
      'descripcion': instance.descripcion,
      'cantidad': instance.cantidad,
      'valor_unitario': instance.valorUnitario,
      'subtotal': instance.subtotal,
      'created_at': instance.createdAt?.toIso8601String(),
    };
