// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Tenant _$TenantFromJson(Map<String, dynamic> json) {
  return _Tenant.fromJson(json);
}

/// @nodoc
mixin _$Tenant {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String? get nit => throw _privateConstructorUsedError;
  @JsonKey(name: 'representante_legal')
  String? get representanteLegal => throw _privateConstructorUsedError;
  @JsonKey(name: 'prefijo_recibos')
  String get prefijoRecibos => throw _privateConstructorUsedError;
  @JsonKey(name: 'cuenta_bancolombia')
  String? get cuentaBancolombia => throw _privateConstructorUsedError;
  @JsonKey(name: 'cuenta_nequi')
  String? get cuentaNequi => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarifa_mora_diaria')
  int get tarifaMoraDiaria => throw _privateConstructorUsedError;
  @JsonKey(name: 'costo_reconexion')
  int get costoReconexion => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarifa_basica')
  int get tarifaBasica => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarifa_extendida')
  int get tarifaExtendida => throw _privateConstructorUsedError;
  @JsonKey(name: 'dias_habiles_pago')
  int get diasHabilesPago => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TenantCopyWith<Tenant> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TenantCopyWith<$Res> {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) then) =
      _$TenantCopyWithImpl<$Res, Tenant>;
  @useResult
  $Res call({
    String id,
    String nombre,
    String? nit,
    @JsonKey(name: 'representante_legal') String? representanteLegal,
    @JsonKey(name: 'prefijo_recibos') String prefijoRecibos,
    @JsonKey(name: 'cuenta_bancolombia') String? cuentaBancolombia,
    @JsonKey(name: 'cuenta_nequi') String? cuentaNequi,
    @JsonKey(name: 'tarifa_mora_diaria') int tarifaMoraDiaria,
    @JsonKey(name: 'costo_reconexion') int costoReconexion,
    @JsonKey(name: 'tarifa_basica') int tarifaBasica,
    @JsonKey(name: 'tarifa_extendida') int tarifaExtendida,
    @JsonKey(name: 'dias_habiles_pago') int diasHabilesPago,
  });
}

/// @nodoc
class _$TenantCopyWithImpl<$Res, $Val extends Tenant>
    implements $TenantCopyWith<$Res> {
  _$TenantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? nit = freezed,
    Object? representanteLegal = freezed,
    Object? prefijoRecibos = null,
    Object? cuentaBancolombia = freezed,
    Object? cuentaNequi = freezed,
    Object? tarifaMoraDiaria = null,
    Object? costoReconexion = null,
    Object? tarifaBasica = null,
    Object? tarifaExtendida = null,
    Object? diasHabilesPago = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            nit: freezed == nit
                ? _value.nit
                : nit // ignore: cast_nullable_to_non_nullable
                      as String?,
            representanteLegal: freezed == representanteLegal
                ? _value.representanteLegal
                : representanteLegal // ignore: cast_nullable_to_non_nullable
                      as String?,
            prefijoRecibos: null == prefijoRecibos
                ? _value.prefijoRecibos
                : prefijoRecibos // ignore: cast_nullable_to_non_nullable
                      as String,
            cuentaBancolombia: freezed == cuentaBancolombia
                ? _value.cuentaBancolombia
                : cuentaBancolombia // ignore: cast_nullable_to_non_nullable
                      as String?,
            cuentaNequi: freezed == cuentaNequi
                ? _value.cuentaNequi
                : cuentaNequi // ignore: cast_nullable_to_non_nullable
                      as String?,
            tarifaMoraDiaria: null == tarifaMoraDiaria
                ? _value.tarifaMoraDiaria
                : tarifaMoraDiaria // ignore: cast_nullable_to_non_nullable
                      as int,
            costoReconexion: null == costoReconexion
                ? _value.costoReconexion
                : costoReconexion // ignore: cast_nullable_to_non_nullable
                      as int,
            tarifaBasica: null == tarifaBasica
                ? _value.tarifaBasica
                : tarifaBasica // ignore: cast_nullable_to_non_nullable
                      as int,
            tarifaExtendida: null == tarifaExtendida
                ? _value.tarifaExtendida
                : tarifaExtendida // ignore: cast_nullable_to_non_nullable
                      as int,
            diasHabilesPago: null == diasHabilesPago
                ? _value.diasHabilesPago
                : diasHabilesPago // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TenantImplCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$$TenantImplCopyWith(
    _$TenantImpl value,
    $Res Function(_$TenantImpl) then,
  ) = __$$TenantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nombre,
    String? nit,
    @JsonKey(name: 'representante_legal') String? representanteLegal,
    @JsonKey(name: 'prefijo_recibos') String prefijoRecibos,
    @JsonKey(name: 'cuenta_bancolombia') String? cuentaBancolombia,
    @JsonKey(name: 'cuenta_nequi') String? cuentaNequi,
    @JsonKey(name: 'tarifa_mora_diaria') int tarifaMoraDiaria,
    @JsonKey(name: 'costo_reconexion') int costoReconexion,
    @JsonKey(name: 'tarifa_basica') int tarifaBasica,
    @JsonKey(name: 'tarifa_extendida') int tarifaExtendida,
    @JsonKey(name: 'dias_habiles_pago') int diasHabilesPago,
  });
}

/// @nodoc
class __$$TenantImplCopyWithImpl<$Res>
    extends _$TenantCopyWithImpl<$Res, _$TenantImpl>
    implements _$$TenantImplCopyWith<$Res> {
  __$$TenantImplCopyWithImpl(
    _$TenantImpl _value,
    $Res Function(_$TenantImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? nit = freezed,
    Object? representanteLegal = freezed,
    Object? prefijoRecibos = null,
    Object? cuentaBancolombia = freezed,
    Object? cuentaNequi = freezed,
    Object? tarifaMoraDiaria = null,
    Object? costoReconexion = null,
    Object? tarifaBasica = null,
    Object? tarifaExtendida = null,
    Object? diasHabilesPago = null,
  }) {
    return _then(
      _$TenantImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        nit: freezed == nit
            ? _value.nit
            : nit // ignore: cast_nullable_to_non_nullable
                  as String?,
        representanteLegal: freezed == representanteLegal
            ? _value.representanteLegal
            : representanteLegal // ignore: cast_nullable_to_non_nullable
                  as String?,
        prefijoRecibos: null == prefijoRecibos
            ? _value.prefijoRecibos
            : prefijoRecibos // ignore: cast_nullable_to_non_nullable
                  as String,
        cuentaBancolombia: freezed == cuentaBancolombia
            ? _value.cuentaBancolombia
            : cuentaBancolombia // ignore: cast_nullable_to_non_nullable
                  as String?,
        cuentaNequi: freezed == cuentaNequi
            ? _value.cuentaNequi
            : cuentaNequi // ignore: cast_nullable_to_non_nullable
                  as String?,
        tarifaMoraDiaria: null == tarifaMoraDiaria
            ? _value.tarifaMoraDiaria
            : tarifaMoraDiaria // ignore: cast_nullable_to_non_nullable
                  as int,
        costoReconexion: null == costoReconexion
            ? _value.costoReconexion
            : costoReconexion // ignore: cast_nullable_to_non_nullable
                  as int,
        tarifaBasica: null == tarifaBasica
            ? _value.tarifaBasica
            : tarifaBasica // ignore: cast_nullable_to_non_nullable
                  as int,
        tarifaExtendida: null == tarifaExtendida
            ? _value.tarifaExtendida
            : tarifaExtendida // ignore: cast_nullable_to_non_nullable
                  as int,
        diasHabilesPago: null == diasHabilesPago
            ? _value.diasHabilesPago
            : diasHabilesPago // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TenantImpl implements _Tenant {
  const _$TenantImpl({
    required this.id,
    required this.nombre,
    this.nit,
    @JsonKey(name: 'representante_legal') this.representanteLegal,
    @JsonKey(name: 'prefijo_recibos') this.prefijoRecibos = 'AC',
    @JsonKey(name: 'cuenta_bancolombia') this.cuentaBancolombia,
    @JsonKey(name: 'cuenta_nequi') this.cuentaNequi,
    @JsonKey(name: 'tarifa_mora_diaria') this.tarifaMoraDiaria = 300,
    @JsonKey(name: 'costo_reconexion') this.costoReconexion = 0,
    @JsonKey(name: 'tarifa_basica') this.tarifaBasica = 18000,
    @JsonKey(name: 'tarifa_extendida') this.tarifaExtendida = 36000,
    @JsonKey(name: 'dias_habiles_pago') this.diasHabilesPago = 5,
  });

  factory _$TenantImpl.fromJson(Map<String, dynamic> json) =>
      _$$TenantImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String? nit;
  @override
  @JsonKey(name: 'representante_legal')
  final String? representanteLegal;
  @override
  @JsonKey(name: 'prefijo_recibos')
  final String prefijoRecibos;
  @override
  @JsonKey(name: 'cuenta_bancolombia')
  final String? cuentaBancolombia;
  @override
  @JsonKey(name: 'cuenta_nequi')
  final String? cuentaNequi;
  @override
  @JsonKey(name: 'tarifa_mora_diaria')
  final int tarifaMoraDiaria;
  @override
  @JsonKey(name: 'costo_reconexion')
  final int costoReconexion;
  @override
  @JsonKey(name: 'tarifa_basica')
  final int tarifaBasica;
  @override
  @JsonKey(name: 'tarifa_extendida')
  final int tarifaExtendida;
  @override
  @JsonKey(name: 'dias_habiles_pago')
  final int diasHabilesPago;

  @override
  String toString() {
    return 'Tenant(id: $id, nombre: $nombre, nit: $nit, representanteLegal: $representanteLegal, prefijoRecibos: $prefijoRecibos, cuentaBancolombia: $cuentaBancolombia, cuentaNequi: $cuentaNequi, tarifaMoraDiaria: $tarifaMoraDiaria, costoReconexion: $costoReconexion, tarifaBasica: $tarifaBasica, tarifaExtendida: $tarifaExtendida, diasHabilesPago: $diasHabilesPago)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TenantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.nit, nit) || other.nit == nit) &&
            (identical(other.representanteLegal, representanteLegal) ||
                other.representanteLegal == representanteLegal) &&
            (identical(other.prefijoRecibos, prefijoRecibos) ||
                other.prefijoRecibos == prefijoRecibos) &&
            (identical(other.cuentaBancolombia, cuentaBancolombia) ||
                other.cuentaBancolombia == cuentaBancolombia) &&
            (identical(other.cuentaNequi, cuentaNequi) ||
                other.cuentaNequi == cuentaNequi) &&
            (identical(other.tarifaMoraDiaria, tarifaMoraDiaria) ||
                other.tarifaMoraDiaria == tarifaMoraDiaria) &&
            (identical(other.costoReconexion, costoReconexion) ||
                other.costoReconexion == costoReconexion) &&
            (identical(other.tarifaBasica, tarifaBasica) ||
                other.tarifaBasica == tarifaBasica) &&
            (identical(other.tarifaExtendida, tarifaExtendida) ||
                other.tarifaExtendida == tarifaExtendida) &&
            (identical(other.diasHabilesPago, diasHabilesPago) ||
                other.diasHabilesPago == diasHabilesPago));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nombre,
    nit,
    representanteLegal,
    prefijoRecibos,
    cuentaBancolombia,
    cuentaNequi,
    tarifaMoraDiaria,
    costoReconexion,
    tarifaBasica,
    tarifaExtendida,
    diasHabilesPago,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TenantImplCopyWith<_$TenantImpl> get copyWith =>
      __$$TenantImplCopyWithImpl<_$TenantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TenantImplToJson(this);
  }
}

abstract class _Tenant implements Tenant {
  const factory _Tenant({
    required final String id,
    required final String nombre,
    final String? nit,
    @JsonKey(name: 'representante_legal') final String? representanteLegal,
    @JsonKey(name: 'prefijo_recibos') final String prefijoRecibos,
    @JsonKey(name: 'cuenta_bancolombia') final String? cuentaBancolombia,
    @JsonKey(name: 'cuenta_nequi') final String? cuentaNequi,
    @JsonKey(name: 'tarifa_mora_diaria') final int tarifaMoraDiaria,
    @JsonKey(name: 'costo_reconexion') final int costoReconexion,
    @JsonKey(name: 'tarifa_basica') final int tarifaBasica,
    @JsonKey(name: 'tarifa_extendida') final int tarifaExtendida,
    @JsonKey(name: 'dias_habiles_pago') final int diasHabilesPago,
  }) = _$TenantImpl;

  factory _Tenant.fromJson(Map<String, dynamic> json) = _$TenantImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  String? get nit;
  @override
  @JsonKey(name: 'representante_legal')
  String? get representanteLegal;
  @override
  @JsonKey(name: 'prefijo_recibos')
  String get prefijoRecibos;
  @override
  @JsonKey(name: 'cuenta_bancolombia')
  String? get cuentaBancolombia;
  @override
  @JsonKey(name: 'cuenta_nequi')
  String? get cuentaNequi;
  @override
  @JsonKey(name: 'tarifa_mora_diaria')
  int get tarifaMoraDiaria;
  @override
  @JsonKey(name: 'costo_reconexion')
  int get costoReconexion;
  @override
  @JsonKey(name: 'tarifa_basica')
  int get tarifaBasica;
  @override
  @JsonKey(name: 'tarifa_extendida')
  int get tarifaExtendida;
  @override
  @JsonKey(name: 'dias_habiles_pago')
  int get diasHabilesPago;
  @override
  @JsonKey(ignore: true)
  _$$TenantImplCopyWith<_$TenantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
