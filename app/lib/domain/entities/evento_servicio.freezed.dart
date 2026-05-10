// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evento_servicio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EventoServicio _$EventoServicioFromJson(Map<String, dynamic> json) {
  return _EventoServicio.fromJson(json);
}

/// @nodoc
mixin _$EventoServicio {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cliente_id')
  String get clienteId => throw _privateConstructorUsedError;
  DateTime get fecha => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
  TipoEventoServicio get tipo => throw _privateConstructorUsedError;
  @JsonKey(name: 'estado_resultante')
  String? get estadoResultante => throw _privateConstructorUsedError;
  String? get motivo => throw _privateConstructorUsedError;
  int? get costo => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventoServicioCopyWith<EventoServicio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventoServicioCopyWith<$Res> {
  factory $EventoServicioCopyWith(
    EventoServicio value,
    $Res Function(EventoServicio) then,
  ) = _$EventoServicioCopyWithImpl<$Res, EventoServicio>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'cliente_id') String clienteId,
    DateTime fecha,
    @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
    TipoEventoServicio tipo,
    @JsonKey(name: 'estado_resultante') String? estadoResultante,
    String? motivo,
    int? costo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$EventoServicioCopyWithImpl<$Res, $Val extends EventoServicio>
    implements $EventoServicioCopyWith<$Res> {
  _$EventoServicioCopyWithImpl(this._value, this._then);

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
    Object? tipo = null,
    Object? estadoResultante = freezed,
    Object? motivo = freezed,
    Object? costo = freezed,
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
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as TipoEventoServicio,
            estadoResultante: freezed == estadoResultante
                ? _value.estadoResultante
                : estadoResultante // ignore: cast_nullable_to_non_nullable
                      as String?,
            motivo: freezed == motivo
                ? _value.motivo
                : motivo // ignore: cast_nullable_to_non_nullable
                      as String?,
            costo: freezed == costo
                ? _value.costo
                : costo // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$EventoServicioImplCopyWith<$Res>
    implements $EventoServicioCopyWith<$Res> {
  factory _$$EventoServicioImplCopyWith(
    _$EventoServicioImpl value,
    $Res Function(_$EventoServicioImpl) then,
  ) = __$$EventoServicioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'cliente_id') String clienteId,
    DateTime fecha,
    @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
    TipoEventoServicio tipo,
    @JsonKey(name: 'estado_resultante') String? estadoResultante,
    String? motivo,
    int? costo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$EventoServicioImplCopyWithImpl<$Res>
    extends _$EventoServicioCopyWithImpl<$Res, _$EventoServicioImpl>
    implements _$$EventoServicioImplCopyWith<$Res> {
  __$$EventoServicioImplCopyWithImpl(
    _$EventoServicioImpl _value,
    $Res Function(_$EventoServicioImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clienteId = null,
    Object? fecha = null,
    Object? tipo = null,
    Object? estadoResultante = freezed,
    Object? motivo = freezed,
    Object? costo = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$EventoServicioImpl(
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
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as TipoEventoServicio,
        estadoResultante: freezed == estadoResultante
            ? _value.estadoResultante
            : estadoResultante // ignore: cast_nullable_to_non_nullable
                  as String?,
        motivo: freezed == motivo
            ? _value.motivo
            : motivo // ignore: cast_nullable_to_non_nullable
                  as String?,
        costo: freezed == costo
            ? _value.costo
            : costo // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$EventoServicioImpl implements _EventoServicio {
  const _$EventoServicioImpl({
    required this.id,
    @JsonKey(name: 'tenant_id') required this.tenantId,
    @JsonKey(name: 'cliente_id') required this.clienteId,
    required this.fecha,
    @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson) required this.tipo,
    @JsonKey(name: 'estado_resultante') this.estadoResultante,
    this.motivo,
    this.costo,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$EventoServicioImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventoServicioImplFromJson(json);

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
  @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
  final TipoEventoServicio tipo;
  @override
  @JsonKey(name: 'estado_resultante')
  final String? estadoResultante;
  @override
  final String? motivo;
  @override
  final int? costo;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'EventoServicio(id: $id, tenantId: $tenantId, clienteId: $clienteId, fecha: $fecha, tipo: $tipo, estadoResultante: $estadoResultante, motivo: $motivo, costo: $costo, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventoServicioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.clienteId, clienteId) ||
                other.clienteId == clienteId) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.estadoResultante, estadoResultante) ||
                other.estadoResultante == estadoResultante) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.costo, costo) || other.costo == costo) &&
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
    tipo,
    estadoResultante,
    motivo,
    costo,
    createdAt,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventoServicioImplCopyWith<_$EventoServicioImpl> get copyWith =>
      __$$EventoServicioImplCopyWithImpl<_$EventoServicioImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventoServicioImplToJson(this);
  }
}

abstract class _EventoServicio implements EventoServicio {
  const factory _EventoServicio({
    required final String id,
    @JsonKey(name: 'tenant_id') required final String tenantId,
    @JsonKey(name: 'cliente_id') required final String clienteId,
    required final DateTime fecha,
    @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
    required final TipoEventoServicio tipo,
    @JsonKey(name: 'estado_resultante') final String? estadoResultante,
    final String? motivo,
    final int? costo,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$EventoServicioImpl;

  factory _EventoServicio.fromJson(Map<String, dynamic> json) =
      _$EventoServicioImpl.fromJson;

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
  @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
  TipoEventoServicio get tipo;
  @override
  @JsonKey(name: 'estado_resultante')
  String? get estadoResultante;
  @override
  String? get motivo;
  @override
  int? get costo;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$EventoServicioImplCopyWith<_$EventoServicioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
