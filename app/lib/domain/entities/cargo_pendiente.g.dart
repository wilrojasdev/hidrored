// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cargo_pendiente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CargoPendienteImpl _$$CargoPendienteImplFromJson(Map<String, dynamic> json) =>
    _$CargoPendienteImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      clienteId: json['cliente_id'] as String,
      conceptoId: json['concepto_id'] as String?,
      descripcion: json['descripcion'] as String,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
      valorUnitario: (json['valor_unitario'] as num).toInt(),
      notas: json['notas'] as String?,
      aplicadoFacturaId: json['aplicado_factura_id'] as String?,
      aplicadoAt: json['aplicado_at'] == null
          ? null
          : DateTime.parse(json['aplicado_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CargoPendienteImplToJson(
  _$CargoPendienteImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenant_id': instance.tenantId,
  'cliente_id': instance.clienteId,
  'concepto_id': instance.conceptoId,
  'descripcion': instance.descripcion,
  'cantidad': instance.cantidad,
  'valor_unitario': instance.valorUnitario,
  'notas': instance.notas,
  'aplicado_factura_id': instance.aplicadoFacturaId,
  'aplicado_at': instance.aplicadoAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
