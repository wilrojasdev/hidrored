import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

/// Datos del tenant (acueducto). Necesarios para reglas de facturacion
/// (tarifa de mora, costo de reconexion, dias habiles de pago, etc.)
@freezed
class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String nombre,
    String? nit,
    @JsonKey(name: 'representante_legal') String? representanteLegal,
    @JsonKey(name: 'prefijo_recibos') @Default('AC') String prefijoRecibos,
    @JsonKey(name: 'cuenta_bancolombia') String? cuentaBancolombia,
    @JsonKey(name: 'cuenta_nequi') String? cuentaNequi,
    @JsonKey(name: 'tarifa_mora_diaria') @Default(300) int tarifaMoraDiaria,
    @JsonKey(name: 'costo_reconexion') @Default(0) int costoReconexion,
    @JsonKey(name: 'tarifa_basica') @Default(18000) int tarifaBasica,
    @JsonKey(name: 'tarifa_extendida') @Default(36000) int tarifaExtendida,
    @JsonKey(name: 'dias_habiles_pago') @Default(5) int diasHabilesPago,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}
