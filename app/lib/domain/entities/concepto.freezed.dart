// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concepto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Concepto _$ConceptoFromJson(Map<String, dynamic> json) {
  return _Concepto.fromJson(json);
}

/// @nodoc
mixin _$Concepto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_default')
  int get valorDefault => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConceptoCopyWith<Concepto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptoCopyWith<$Res> {
  factory $ConceptoCopyWith(Concepto value, $Res Function(Concepto) then) =
      _$ConceptoCopyWithImpl<$Res, Concepto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    String nombre,
    @JsonKey(name: 'valor_default') int valorDefault,
    String? descripcion,
    bool activo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$ConceptoCopyWithImpl<$Res, $Val extends Concepto>
    implements $ConceptoCopyWith<$Res> {
  _$ConceptoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? nombre = null,
    Object? valorDefault = null,
    Object? descripcion = freezed,
    Object? activo = null,
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
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            valorDefault: null == valorDefault
                ? _value.valorDefault
                : valorDefault // ignore: cast_nullable_to_non_nullable
                      as int,
            descripcion: freezed == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String?,
            activo: null == activo
                ? _value.activo
                : activo // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$ConceptoImplCopyWith<$Res>
    implements $ConceptoCopyWith<$Res> {
  factory _$$ConceptoImplCopyWith(
    _$ConceptoImpl value,
    $Res Function(_$ConceptoImpl) then,
  ) = __$$ConceptoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    String nombre,
    @JsonKey(name: 'valor_default') int valorDefault,
    String? descripcion,
    bool activo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$ConceptoImplCopyWithImpl<$Res>
    extends _$ConceptoCopyWithImpl<$Res, _$ConceptoImpl>
    implements _$$ConceptoImplCopyWith<$Res> {
  __$$ConceptoImplCopyWithImpl(
    _$ConceptoImpl _value,
    $Res Function(_$ConceptoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? nombre = null,
    Object? valorDefault = null,
    Object? descripcion = freezed,
    Object? activo = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ConceptoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        valorDefault: null == valorDefault
            ? _value.valorDefault
            : valorDefault // ignore: cast_nullable_to_non_nullable
                  as int,
        descripcion: freezed == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String?,
        activo: null == activo
            ? _value.activo
            : activo // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$ConceptoImpl implements _Concepto {
  const _$ConceptoImpl({
    required this.id,
    @JsonKey(name: 'tenant_id') required this.tenantId,
    required this.nombre,
    @JsonKey(name: 'valor_default') this.valorDefault = 0,
    this.descripcion,
    this.activo = true,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$ConceptoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  final String nombre;
  @override
  @JsonKey(name: 'valor_default')
  final int valorDefault;
  @override
  final String? descripcion;
  @override
  @JsonKey()
  final bool activo;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Concepto(id: $id, tenantId: $tenantId, nombre: $nombre, valorDefault: $valorDefault, descripcion: $descripcion, activo: $activo, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.valorDefault, valorDefault) ||
                other.valorDefault == valorDefault) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.activo, activo) || other.activo == activo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    nombre,
    valorDefault,
    descripcion,
    activo,
    createdAt,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptoImplCopyWith<_$ConceptoImpl> get copyWith =>
      __$$ConceptoImplCopyWithImpl<_$ConceptoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptoImplToJson(this);
  }
}

abstract class _Concepto implements Concepto {
  const factory _Concepto({
    required final String id,
    @JsonKey(name: 'tenant_id') required final String tenantId,
    required final String nombre,
    @JsonKey(name: 'valor_default') final int valorDefault,
    final String? descripcion,
    final bool activo,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$ConceptoImpl;

  factory _Concepto.fromJson(Map<String, dynamic> json) =
      _$ConceptoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  String get nombre;
  @override
  @JsonKey(name: 'valor_default')
  int get valorDefault;
  @override
  String? get descripcion;
  @override
  bool get activo;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ConceptoImplCopyWith<_$ConceptoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
