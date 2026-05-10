// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pago_factura.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PagoFacturaImpl _$$PagoFacturaImplFromJson(Map<String, dynamic> json) =>
    _$PagoFacturaImpl(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      pagoId: json['pago_id'] as String,
      facturaId: json['factura_id'] as String,
      montoAplicado: (json['monto_aplicado'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$PagoFacturaImplToJson(_$PagoFacturaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'pago_id': instance.pagoId,
      'factura_id': instance.facturaId,
      'monto_aplicado': instance.montoAplicado,
      'created_at': instance.createdAt?.toIso8601String(),
    };
