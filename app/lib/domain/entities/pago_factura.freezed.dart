// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pago_factura.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PagoFactura _$PagoFacturaFromJson(Map<String, dynamic> json) {
  return _PagoFactura.fromJson(json);
}

/// @nodoc
mixin _$PagoFactura {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'pago_id')
  String get pagoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'factura_id')
  String get facturaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'monto_aplicado')
  int get montoAplicado => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PagoFacturaCopyWith<PagoFactura> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PagoFacturaCopyWith<$Res> {
  factory $PagoFacturaCopyWith(
    PagoFactura value,
    $Res Function(PagoFactura) then,
  ) = _$PagoFacturaCopyWithImpl<$Res, PagoFactura>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'pago_id') String pagoId,
    @JsonKey(name: 'factura_id') String facturaId,
    @JsonKey(name: 'monto_aplicado') int montoAplicado,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$PagoFacturaCopyWithImpl<$Res, $Val extends PagoFactura>
    implements $PagoFacturaCopyWith<$Res> {
  _$PagoFacturaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? pagoId = null,
    Object? facturaId = null,
    Object? montoAplicado = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            pagoId: null == pagoId
                ? _value.pagoId
                : pagoId // ignore: cast_nullable_to_non_nullable
                      as String,
            facturaId: null == facturaId
                ? _value.facturaId
                : facturaId // ignore: cast_nullable_to_non_nullable
                      as String,
            montoAplicado: null == montoAplicado
                ? _value.montoAplicado
                : montoAplicado // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PagoFacturaImplCopyWith<$Res>
    implements $PagoFacturaCopyWith<$Res> {
  factory _$$PagoFacturaImplCopyWith(
    _$PagoFacturaImpl value,
    $Res Function(_$PagoFacturaImpl) then,
  ) = __$$PagoFacturaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'pago_id') String pagoId,
    @JsonKey(name: 'factura_id') String facturaId,
    @JsonKey(name: 'monto_aplicado') int montoAplicado,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$PagoFacturaImplCopyWithImpl<$Res>
    extends _$PagoFacturaCopyWithImpl<$Res, _$PagoFacturaImpl>
    implements _$$PagoFacturaImplCopyWith<$Res> {
  __$$PagoFacturaImplCopyWithImpl(
    _$PagoFacturaImpl _value,
    $Res Function(_$PagoFacturaImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? pagoId = null,
    Object? facturaId = null,
    Object? montoAplicado = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PagoFacturaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        pagoId: null == pagoId
            ? _value.pagoId
            : pagoId // ignore: cast_nullable_to_non_nullable
                  as String,
        facturaId: null == facturaId
            ? _value.facturaId
            : facturaId // ignore: cast_nullable_to_non_nullable
                  as String,
        montoAplicado: null == montoAplicado
            ? _value.montoAplicado
            : montoAplicado // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PagoFacturaImpl implements _PagoFactura {
  const _$PagoFacturaImpl({
    required this.id,
    @JsonKey(name: 'tenant_id') required this.tenantId,
    @JsonKey(name: 'pago_id') required this.pagoId,
    @JsonKey(name: 'factura_id') required this.facturaId,
    @JsonKey(name: 'monto_aplicado') required this.montoAplicado,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$PagoFacturaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PagoFacturaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  @JsonKey(name: 'pago_id')
  final String pagoId;
  @override
  @JsonKey(name: 'factura_id')
  final String facturaId;
  @override
  @JsonKey(name: 'monto_aplicado')
  final int montoAplicado;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PagoFactura(id: $id, tenantId: $tenantId, pagoId: $pagoId, facturaId: $facturaId, montoAplicado: $montoAplicado, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PagoFacturaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.pagoId, pagoId) || other.pagoId == pagoId) &&
            (identical(other.facturaId, facturaId) ||
                other.facturaId == facturaId) &&
            (identical(other.montoAplicado, montoAplicado) ||
                other.montoAplicado == montoAplicado) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    pagoId,
    facturaId,
    montoAplicado,
    createdAt,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PagoFacturaImplCopyWith<_$PagoFacturaImpl> get copyWith =>
      __$$PagoFacturaImplCopyWithImpl<_$PagoFacturaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PagoFacturaImplToJson(this);
  }
}

abstract class _PagoFactura implements PagoFactura {
  const factory _PagoFactura({
    required final String id,
    @JsonKey(name: 'tenant_id') required final String tenantId,
    @JsonKey(name: 'pago_id') required final String pagoId,
    @JsonKey(name: 'factura_id') required final String facturaId,
    @JsonKey(name: 'monto_aplicado') required final int montoAplicado,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$PagoFacturaImpl;

  factory _PagoFactura.fromJson(Map<String, dynamic> json) =
      _$PagoFacturaImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  @JsonKey(name: 'pago_id')
  String get pagoId;
  @override
  @JsonKey(name: 'factura_id')
  String get facturaId;
  @override
  @JsonKey(name: 'monto_aplicado')
  int get montoAplicado;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$PagoFacturaImplCopyWith<_$PagoFacturaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
