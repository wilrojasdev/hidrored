// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pago.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Pago _$PagoFromJson(Map<String, dynamic> json) {
  return _Pago.fromJson(json);
}

/// @nodoc
mixin _$Pago {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cliente_id')
  String get clienteId => throw _privateConstructorUsedError;
  DateTime get fecha => throw _privateConstructorUsedError;
  int get valor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
  MetodoPago get metodo => throw _privateConstructorUsedError;
  String? get referencia => throw _privateConstructorUsedError;
  String? get notas => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PagoCopyWith<Pago> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PagoCopyWith<$Res> {
  factory $PagoCopyWith(Pago value, $Res Function(Pago) then) =
      _$PagoCopyWithImpl<$Res, Pago>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'cliente_id') String clienteId,
    DateTime fecha,
    int valor,
    @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
    MetodoPago metodo,
    String? referencia,
    String? notas,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$PagoCopyWithImpl<$Res, $Val extends Pago>
    implements $PagoCopyWith<$Res> {
  _$PagoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clienteId = null,
    Object? fecha = null,
    Object? valor = null,
    Object? metodo = null,
    Object? referencia = freezed,
    Object? notas = freezed,
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
            clienteId: null == clienteId
                ? _value.clienteId
                : clienteId // ignore: cast_nullable_to_non_nullable
                      as String,
            fecha: null == fecha
                ? _value.fecha
                : fecha // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            valor: null == valor
                ? _value.valor
                : valor // ignore: cast_nullable_to_non_nullable
                      as int,
            metodo: null == metodo
                ? _value.metodo
                : metodo // ignore: cast_nullable_to_non_nullable
                      as MetodoPago,
            referencia: freezed == referencia
                ? _value.referencia
                : referencia // ignore: cast_nullable_to_non_nullable
                      as String?,
            notas: freezed == notas
                ? _value.notas
                : notas // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$PagoImplCopyWith<$Res> implements $PagoCopyWith<$Res> {
  factory _$$PagoImplCopyWith(
    _$PagoImpl value,
    $Res Function(_$PagoImpl) then,
  ) = __$$PagoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'cliente_id') String clienteId,
    DateTime fecha,
    int valor,
    @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
    MetodoPago metodo,
    String? referencia,
    String? notas,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$PagoImplCopyWithImpl<$Res>
    extends _$PagoCopyWithImpl<$Res, _$PagoImpl>
    implements _$$PagoImplCopyWith<$Res> {
  __$$PagoImplCopyWithImpl(_$PagoImpl _value, $Res Function(_$PagoImpl) _then)
    : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clienteId = null,
    Object? fecha = null,
    Object? valor = null,
    Object? metodo = null,
    Object? referencia = freezed,
    Object? notas = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PagoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        clienteId: null == clienteId
            ? _value.clienteId
            : clienteId // ignore: cast_nullable_to_non_nullable
                  as String,
        fecha: null == fecha
            ? _value.fecha
            : fecha // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        valor: null == valor
            ? _value.valor
            : valor // ignore: cast_nullable_to_non_nullable
                  as int,
        metodo: null == metodo
            ? _value.metodo
            : metodo // ignore: cast_nullable_to_non_nullable
                  as MetodoPago,
        referencia: freezed == referencia
            ? _value.referencia
            : referencia // ignore: cast_nullable_to_non_nullable
                  as String?,
        notas: freezed == notas
            ? _value.notas
            : notas // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$PagoImpl implements _Pago {
  const _$PagoImpl({
    required this.id,
    @JsonKey(name: 'tenant_id') required this.tenantId,
    @JsonKey(name: 'cliente_id') required this.clienteId,
    required this.fecha,
    required this.valor,
    @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
    required this.metodo,
    this.referencia,
    this.notas,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$PagoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PagoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  final String clienteId;
  @override
  final DateTime fecha;
  @override
  final int valor;
  @override
  @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
  final MetodoPago metodo;
  @override
  final String? referencia;
  @override
  final String? notas;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Pago(id: $id, tenantId: $tenantId, clienteId: $clienteId, fecha: $fecha, valor: $valor, metodo: $metodo, referencia: $referencia, notas: $notas, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PagoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.clienteId, clienteId) ||
                other.clienteId == clienteId) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.valor, valor) || other.valor == valor) &&
            (identical(other.metodo, metodo) || other.metodo == metodo) &&
            (identical(other.referencia, referencia) ||
                other.referencia == referencia) &&
            (identical(other.notas, notas) || other.notas == notas) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    clienteId,
    fecha,
    valor,
    metodo,
    referencia,
    notas,
    createdAt,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PagoImplCopyWith<_$PagoImpl> get copyWith =>
      __$$PagoImplCopyWithImpl<_$PagoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PagoImplToJson(this);
  }
}

abstract class _Pago implements Pago {
  const factory _Pago({
    required final String id,
    @JsonKey(name: 'tenant_id') required final String tenantId,
    @JsonKey(name: 'cliente_id') required final String clienteId,
    required final DateTime fecha,
    required final int valor,
    @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
    required final MetodoPago metodo,
    final String? referencia,
    final String? notas,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$PagoImpl;

  factory _Pago.fromJson(Map<String, dynamic> json) = _$PagoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  String get clienteId;
  @override
  DateTime get fecha;
  @override
  int get valor;
  @override
  @JsonKey(fromJson: _metodoFromJson, toJson: _metodoToJson)
  MetodoPago get metodo;
  @override
  String? get referencia;
  @override
  String? get notas;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$PagoImplCopyWith<_$PagoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
