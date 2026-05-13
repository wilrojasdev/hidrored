// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dano.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Dano _$DanoFromJson(Map<String, dynamic> json) {
  return _Dano.fromJson(json);
}

/// @nodoc
mixin _$Dano {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cliente_id')
  String get clienteId => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_reporte')
  DateTime get fechaReporte => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_solucion')
  DateTime? get fechaSolucion => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  int get costo => throw _privateConstructorUsedError;
  @JsonKey(name: 'reportado_por')
  String? get reportadoPor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  EstadoDano get estado => throw _privateConstructorUsedError;
  String? get notas => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DanoCopyWith<Dano> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DanoCopyWith<$Res> {
  factory $DanoCopyWith(Dano value, $Res Function(Dano) then) =
      _$DanoCopyWithImpl<$Res, Dano>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      @JsonKey(name: 'cliente_id') String clienteId,
      @JsonKey(name: 'fecha_reporte') DateTime fechaReporte,
      @JsonKey(name: 'fecha_solucion') DateTime? fechaSolucion,
      String descripcion,
      int costo,
      @JsonKey(name: 'reportado_por') String? reportadoPor,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      EstadoDano estado,
      String? notas,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$DanoCopyWithImpl<$Res, $Val extends Dano>
    implements $DanoCopyWith<$Res> {
  _$DanoCopyWithImpl(this._value, this._then);

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
    Object? fechaReporte = null,
    Object? fechaSolucion = freezed,
    Object? descripcion = null,
    Object? costo = null,
    Object? reportadoPor = freezed,
    Object? estado = null,
    Object? notas = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      clienteId: null == clienteId
          ? _value.clienteId
          : clienteId // ignore: cast_nullable_to_non_nullable
              as String,
      fechaReporte: null == fechaReporte
          ? _value.fechaReporte
          : fechaReporte // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaSolucion: freezed == fechaSolucion
          ? _value.fechaSolucion
          : fechaSolucion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      costo: null == costo
          ? _value.costo
          : costo // ignore: cast_nullable_to_non_nullable
              as int,
      reportadoPor: freezed == reportadoPor
          ? _value.reportadoPor
          : reportadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoDano,
      notas: freezed == notas
          ? _value.notas
          : notas // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DanoImplCopyWith<$Res> implements $DanoCopyWith<$Res> {
  factory _$$DanoImplCopyWith(
          _$DanoImpl value, $Res Function(_$DanoImpl) then) =
      __$$DanoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      @JsonKey(name: 'cliente_id') String clienteId,
      @JsonKey(name: 'fecha_reporte') DateTime fechaReporte,
      @JsonKey(name: 'fecha_solucion') DateTime? fechaSolucion,
      String descripcion,
      int costo,
      @JsonKey(name: 'reportado_por') String? reportadoPor,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      EstadoDano estado,
      String? notas,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$DanoImplCopyWithImpl<$Res>
    extends _$DanoCopyWithImpl<$Res, _$DanoImpl>
    implements _$$DanoImplCopyWith<$Res> {
  __$$DanoImplCopyWithImpl(_$DanoImpl _value, $Res Function(_$DanoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clienteId = null,
    Object? fechaReporte = null,
    Object? fechaSolucion = freezed,
    Object? descripcion = null,
    Object? costo = null,
    Object? reportadoPor = freezed,
    Object? estado = null,
    Object? notas = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DanoImpl(
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
      fechaReporte: null == fechaReporte
          ? _value.fechaReporte
          : fechaReporte // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaSolucion: freezed == fechaSolucion
          ? _value.fechaSolucion
          : fechaSolucion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      costo: null == costo
          ? _value.costo
          : costo // ignore: cast_nullable_to_non_nullable
              as int,
      reportadoPor: freezed == reportadoPor
          ? _value.reportadoPor
          : reportadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoDano,
      notas: freezed == notas
          ? _value.notas
          : notas // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DanoImpl implements _Dano {
  const _$DanoImpl(
      {required this.id,
      @JsonKey(name: 'tenant_id') required this.tenantId,
      @JsonKey(name: 'cliente_id') required this.clienteId,
      @JsonKey(name: 'fecha_reporte') required this.fechaReporte,
      @JsonKey(name: 'fecha_solucion') this.fechaSolucion,
      required this.descripcion,
      this.costo = 0,
      @JsonKey(name: 'reportado_por') this.reportadoPor,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      this.estado = EstadoDano.reportado,
      this.notas,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$DanoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DanoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  final String clienteId;
  @override
  @JsonKey(name: 'fecha_reporte')
  final DateTime fechaReporte;
  @override
  @JsonKey(name: 'fecha_solucion')
  final DateTime? fechaSolucion;
  @override
  final String descripcion;
  @override
  @JsonKey()
  final int costo;
  @override
  @JsonKey(name: 'reportado_por')
  final String? reportadoPor;
  @override
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  final EstadoDano estado;
  @override
  final String? notas;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Dano(id: $id, tenantId: $tenantId, clienteId: $clienteId, fechaReporte: $fechaReporte, fechaSolucion: $fechaSolucion, descripcion: $descripcion, costo: $costo, reportadoPor: $reportadoPor, estado: $estado, notas: $notas, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DanoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.clienteId, clienteId) ||
                other.clienteId == clienteId) &&
            (identical(other.fechaReporte, fechaReporte) ||
                other.fechaReporte == fechaReporte) &&
            (identical(other.fechaSolucion, fechaSolucion) ||
                other.fechaSolucion == fechaSolucion) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.costo, costo) || other.costo == costo) &&
            (identical(other.reportadoPor, reportadoPor) ||
                other.reportadoPor == reportadoPor) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.notas, notas) || other.notas == notas) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      clienteId,
      fechaReporte,
      fechaSolucion,
      descripcion,
      costo,
      reportadoPor,
      estado,
      notas,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DanoImplCopyWith<_$DanoImpl> get copyWith =>
      __$$DanoImplCopyWithImpl<_$DanoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DanoImplToJson(
      this,
    );
  }
}

abstract class _Dano implements Dano {
  const factory _Dano(
      {required final String id,
      @JsonKey(name: 'tenant_id') required final String tenantId,
      @JsonKey(name: 'cliente_id') required final String clienteId,
      @JsonKey(name: 'fecha_reporte') required final DateTime fechaReporte,
      @JsonKey(name: 'fecha_solucion') final DateTime? fechaSolucion,
      required final String descripcion,
      final int costo,
      @JsonKey(name: 'reportado_por') final String? reportadoPor,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      final EstadoDano estado,
      final String? notas,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$DanoImpl;

  factory _Dano.fromJson(Map<String, dynamic> json) = _$DanoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  String get clienteId;
  @override
  @JsonKey(name: 'fecha_reporte')
  DateTime get fechaReporte;
  @override
  @JsonKey(name: 'fecha_solucion')
  DateTime? get fechaSolucion;
  @override
  String get descripcion;
  @override
  int get costo;
  @override
  @JsonKey(name: 'reportado_por')
  String? get reportadoPor;
  @override
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  EstadoDano get estado;
  @override
  String? get notas;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$DanoImplCopyWith<_$DanoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
