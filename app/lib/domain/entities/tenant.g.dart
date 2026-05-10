// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TenantImpl _$$TenantImplFromJson(Map<String, dynamic> json) => _$TenantImpl(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  nit: json['nit'] as String?,
  representanteLegal: json['representante_legal'] as String?,
  prefijoRecibos: json['prefijo_recibos'] as String? ?? 'AC',
  cuentaBancolombia: json['cuenta_bancolombia'] as String?,
  cuentaNequi: json['cuenta_nequi'] as String?,
  tarifaMoraDiaria: (json['tarifa_mora_diaria'] as num?)?.toInt() ?? 300,
  costoReconexion: (json['costo_reconexion'] as num?)?.toInt() ?? 0,
  tarifaBasica: (json['tarifa_basica'] as num?)?.toInt() ?? 18000,
  tarifaExtendida: (json['tarifa_extendida'] as num?)?.toInt() ?? 36000,
  diasHabilesPago: (json['dias_habiles_pago'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$$TenantImplToJson(_$TenantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'nit': instance.nit,
      'representante_legal': instance.representanteLegal,
      'prefijo_recibos': instance.prefijoRecibos,
      'cuenta_bancolombia': instance.cuentaBancolombia,
      'cuenta_nequi': instance.cuentaNequi,
      'tarifa_mora_diaria': instance.tarifaMoraDiaria,
      'costo_reconexion': instance.costoReconexion,
      'tarifa_basica': instance.tarifaBasica,
      'tarifa_extendida': instance.tarifaExtendida,
      'dias_habiles_pago': instance.diasHabilesPago,
    };
