// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'factura_linea.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FacturaLinea _$FacturaLineaFromJson(Map<String, dynamic> json) {
  return _FacturaLinea.fromJson(json);
}

/// @nodoc
mixin _$FacturaLinea {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'factura_id')
  String get facturaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'concepto_id')
  String? get conceptoId => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  int get cantidad => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_unitario')
  int get valorUnitario => throw _privateConstructorUsedError;
  int get subtotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'factura_origen_id')
  String? get facturaOrigenId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FacturaLineaCopyWith<FacturaLinea> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacturaLineaCopyWith<$Res> {
  factory $FacturaLineaCopyWith(
          FacturaLinea value, $Res Function(FacturaLinea) then) =
      _$FacturaLineaCopyWithImpl<$Res, FacturaLinea>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      @JsonKey(name: 'factura_id') String facturaId,
      @JsonKey(name: 'concepto_id') String? conceptoId,
      String descripcion,
      int cantidad,
      @JsonKey(name: 'valor_unitario') int valorUnitario,
      int subtotal,
      @JsonKey(name: 'factura_origen_id') String? facturaOrigenId,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$FacturaLineaCopyWithImpl<$Res, $Val extends FacturaLinea>
    implements $FacturaLineaCopyWith<$Res> {
  _$FacturaLineaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? facturaId = null,
    Object? conceptoId = freezed,
    Object? descripcion = null,
    Object? cantidad = null,
    Object? valorUnitario = null,
    Object? subtotal = null,
    Object? facturaOrigenId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      facturaId: null == facturaId
          ? _value.facturaId
          : facturaId // ignore: cast_nullable_to_non_nullable
              as String,
      conceptoId: freezed == conceptoId
          ? _value.conceptoId
          : conceptoId // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      cantidad: null == cantidad
          ? _value.cantidad
          : cantidad // ignore: cast_nullable_to_non_nullable
              as int,
      valorUnitario: null == valorUnitario
          ? _value.valorUnitario
          : valorUnitario // ignore: cast_nullable_to_non_nullable
              as int,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      facturaOrigenId: freezed == facturaOrigenId
          ? _value.facturaOrigenId
          : facturaOrigenId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FacturaLineaImplCopyWith<$Res>
    implements $FacturaLineaCopyWith<$Res> {
  factory _$$FacturaLineaImplCopyWith(
          _$FacturaLineaImpl value, $Res Function(_$FacturaLineaImpl) then) =
      __$$FacturaLineaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      @JsonKey(name: 'factura_id') String facturaId,
      @JsonKey(name: 'concepto_id') String? conceptoId,
      String descripcion,
      int cantidad,
      @JsonKey(name: 'valor_unitario') int valorUnitario,
      int subtotal,
      @JsonKey(name: 'factura_origen_id') String? facturaOrigenId,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$FacturaLineaImplCopyWithImpl<$Res>
    extends _$FacturaLineaCopyWithImpl<$Res, _$FacturaLineaImpl>
    implements _$$FacturaLineaImplCopyWith<$Res> {
  __$$FacturaLineaImplCopyWithImpl(
      _$FacturaLineaImpl _value, $Res Function(_$FacturaLineaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? facturaId = null,
    Object? conceptoId = freezed,
    Object? descripcion = null,
    Object? cantidad = null,
    Object? valorUnitario = null,
    Object? subtotal = null,
    Object? facturaOrigenId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$FacturaLineaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      facturaId: null == facturaId
          ? _value.facturaId
          : facturaId // ignore: cast_nullable_to_non_nullable
              as String,
      conceptoId: freezed == conceptoId
          ? _value.conceptoId
          : conceptoId // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      cantidad: null == cantidad
          ? _value.cantidad
          : cantidad // ignore: cast_nullable_to_non_nullable
              as int,
      valorUnitario: null == valorUnitario
          ? _value.valorUnitario
          : valorUnitario // ignore: cast_nullable_to_non_nullable
              as int,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      facturaOrigenId: freezed == facturaOrigenId
          ? _value.facturaOrigenId
          : facturaOrigenId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FacturaLineaImpl implements _FacturaLinea {
  const _$FacturaLineaImpl(
      {required this.id,
      @JsonKey(name: 'tenant_id') required this.tenantId,
      @JsonKey(name: 'factura_id') required this.facturaId,
      @JsonKey(name: 'concepto_id') this.conceptoId,
      required this.descripcion,
      this.cantidad = 1,
      @JsonKey(name: 'valor_unitario') required this.valorUnitario,
      required this.subtotal,
      @JsonKey(name: 'factura_origen_id') this.facturaOrigenId,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$FacturaLineaImpl.fromJson(Map<String, dynamic> json) =>
      _$$FacturaLineaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  @JsonKey(name: 'factura_id')
  final String facturaId;
  @override
  @JsonKey(name: 'concepto_id')
  final String? conceptoId;
  @override
  final String descripcion;
  @override
  @JsonKey()
  final int cantidad;
  @override
  @JsonKey(name: 'valor_unitario')
  final int valorUnitario;
  @override
  final int subtotal;
  @override
  @JsonKey(name: 'factura_origen_id')
  final String? facturaOrigenId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'FacturaLinea(id: $id, tenantId: $tenantId, facturaId: $facturaId, conceptoId: $conceptoId, descripcion: $descripcion, cantidad: $cantidad, valorUnitario: $valorUnitario, subtotal: $subtotal, facturaOrigenId: $facturaOrigenId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacturaLineaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.facturaId, facturaId) ||
                other.facturaId == facturaId) &&
            (identical(other.conceptoId, conceptoId) ||
                other.conceptoId == conceptoId) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.cantidad, cantidad) ||
                other.cantidad == cantidad) &&
            (identical(other.valorUnitario, valorUnitario) ||
                other.valorUnitario == valorUnitario) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.facturaOrigenId, facturaOrigenId) ||
                other.facturaOrigenId == facturaOrigenId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      facturaId,
      conceptoId,
      descripcion,
      cantidad,
      valorUnitario,
      subtotal,
      facturaOrigenId,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FacturaLineaImplCopyWith<_$FacturaLineaImpl> get copyWith =>
      __$$FacturaLineaImplCopyWithImpl<_$FacturaLineaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FacturaLineaImplToJson(
      this,
    );
  }
}

abstract class _FacturaLinea implements FacturaLinea {
  const factory _FacturaLinea(
          {required final String id,
          @JsonKey(name: 'tenant_id') required final String tenantId,
          @JsonKey(name: 'factura_id') required final String facturaId,
          @JsonKey(name: 'concepto_id') final String? conceptoId,
          required final String descripcion,
          final int cantidad,
          @JsonKey(name: 'valor_unitario') required final int valorUnitario,
          required final int subtotal,
          @JsonKey(name: 'factura_origen_id') final String? facturaOrigenId,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$FacturaLineaImpl;

  factory _FacturaLinea.fromJson(Map<String, dynamic> json) =
      _$FacturaLineaImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  @JsonKey(name: 'factura_id')
  String get facturaId;
  @override
  @JsonKey(name: 'concepto_id')
  String? get conceptoId;
  @override
  String get descripcion;
  @override
  int get cantidad;
  @override
  @JsonKey(name: 'valor_unitario')
  int get valorUnitario;
  @override
  int get subtotal;
  @override
  @JsonKey(name: 'factura_origen_id')
  String? get facturaOrigenId;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$FacturaLineaImplCopyWith<_$FacturaLineaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
