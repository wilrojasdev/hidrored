// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Perfil _$PerfilFromJson(Map<String, dynamic> json) {
  return _Perfil.fromJson(json);
}

/// @nodoc
mixin _$Perfil {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get rol => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PerfilCopyWith<Perfil> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerfilCopyWith<$Res> {
  factory $PerfilCopyWith(Perfil value, $Res Function(Perfil) then) =
      _$PerfilCopyWithImpl<$Res, Perfil>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    String nombre,
    String email,
    String rol,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$PerfilCopyWithImpl<$Res, $Val extends Perfil>
    implements $PerfilCopyWith<$Res> {
  _$PerfilCopyWithImpl(this._value, this._then);

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
    Object? email = null,
    Object? rol = null,
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
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            rol: null == rol
                ? _value.rol
                : rol // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$PerfilImplCopyWith<$Res> implements $PerfilCopyWith<$Res> {
  factory _$$PerfilImplCopyWith(
    _$PerfilImpl value,
    $Res Function(_$PerfilImpl) then,
  ) = __$$PerfilImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    String nombre,
    String email,
    String rol,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$PerfilImplCopyWithImpl<$Res>
    extends _$PerfilCopyWithImpl<$Res, _$PerfilImpl>
    implements _$$PerfilImplCopyWith<$Res> {
  __$$PerfilImplCopyWithImpl(
    _$PerfilImpl _value,
    $Res Function(_$PerfilImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? nombre = null,
    Object? email = null,
    Object? rol = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PerfilImpl(
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
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        rol: null == rol
            ? _value.rol
            : rol // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$PerfilImpl implements _Perfil {
  const _$PerfilImpl({
    required this.id,
    @JsonKey(name: 'tenant_id') required this.tenantId,
    required this.nombre,
    required this.email,
    this.rol = 'admin',
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$PerfilImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerfilImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  final String nombre;
  @override
  final String email;
  @override
  @JsonKey()
  final String rol;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Perfil(id: $id, tenantId: $tenantId, nombre: $nombre, email: $email, rol: $rol, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerfilImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.rol, rol) || other.rol == rol) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, tenantId, nombre, email, rol, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PerfilImplCopyWith<_$PerfilImpl> get copyWith =>
      __$$PerfilImplCopyWithImpl<_$PerfilImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PerfilImplToJson(this);
  }
}

abstract class _Perfil implements Perfil {
  const factory _Perfil({
    required final String id,
    @JsonKey(name: 'tenant_id') required final String tenantId,
    required final String nombre,
    required final String email,
    final String rol,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$PerfilImpl;

  factory _Perfil.fromJson(Map<String, dynamic> json) = _$PerfilImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  String get nombre;
  @override
  String get email;
  @override
  String get rol;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$PerfilImplCopyWith<_$PerfilImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
