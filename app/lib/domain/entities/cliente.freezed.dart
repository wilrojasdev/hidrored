// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cliente.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Cliente _$ClienteFromJson(Map<String, dynamic> json) {
  return _Cliente.fromJson(json);
}

/// @nodoc
mixin _$Cliente {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  int get codigo => throw _privateConstructorUsedError;
  String get cedula => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String? get direccion => throw _privateConstructorUsedError;
  String? get telefono => throw _privateConstructorUsedError;
  String? get sector => throw _privateConstructorUsedError;
  String? get zona => throw _privateConstructorUsedError;
  String? get barrio => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarifa_mensual')
  int get tarifaMensual => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  EstadoCliente get estado => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_ingreso')
  DateTime get fechaIngreso => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_retiro')
  DateTime? get fechaRetiro => throw _privateConstructorUsedError;
  @JsonKey(name: 'deuda_inicial')
  int get deudaInicial => throw _privateConstructorUsedError;
  String? get notas => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClienteCopyWith<Cliente> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClienteCopyWith<$Res> {
  factory $ClienteCopyWith(Cliente value, $Res Function(Cliente) then) =
      _$ClienteCopyWithImpl<$Res, Cliente>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      int codigo,
      String cedula,
      String nombre,
      String? direccion,
      String? telefono,
      String? sector,
      String? zona,
      String? barrio,
      @JsonKey(name: 'tarifa_mensual') int tarifaMensual,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      EstadoCliente estado,
      @JsonKey(name: 'fecha_ingreso') DateTime fechaIngreso,
      @JsonKey(name: 'fecha_retiro') DateTime? fechaRetiro,
      @JsonKey(name: 'deuda_inicial') int deudaInicial,
      String? notas,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ClienteCopyWithImpl<$Res, $Val extends Cliente>
    implements $ClienteCopyWith<$Res> {
  _$ClienteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? codigo = null,
    Object? cedula = null,
    Object? nombre = null,
    Object? direccion = freezed,
    Object? telefono = freezed,
    Object? sector = freezed,
    Object? zona = freezed,
    Object? barrio = freezed,
    Object? tarifaMensual = null,
    Object? estado = null,
    Object? fechaIngreso = null,
    Object? fechaRetiro = freezed,
    Object? deudaInicial = null,
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
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as int,
      cedula: null == cedula
          ? _value.cedula
          : cedula // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      telefono: freezed == telefono
          ? _value.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _value.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      zona: freezed == zona
          ? _value.zona
          : zona // ignore: cast_nullable_to_non_nullable
              as String?,
      barrio: freezed == barrio
          ? _value.barrio
          : barrio // ignore: cast_nullable_to_non_nullable
              as String?,
      tarifaMensual: null == tarifaMensual
          ? _value.tarifaMensual
          : tarifaMensual // ignore: cast_nullable_to_non_nullable
              as int,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoCliente,
      fechaIngreso: null == fechaIngreso
          ? _value.fechaIngreso
          : fechaIngreso // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaRetiro: freezed == fechaRetiro
          ? _value.fechaRetiro
          : fechaRetiro // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deudaInicial: null == deudaInicial
          ? _value.deudaInicial
          : deudaInicial // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ClienteImplCopyWith<$Res> implements $ClienteCopyWith<$Res> {
  factory _$$ClienteImplCopyWith(
          _$ClienteImpl value, $Res Function(_$ClienteImpl) then) =
      __$$ClienteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      int codigo,
      String cedula,
      String nombre,
      String? direccion,
      String? telefono,
      String? sector,
      String? zona,
      String? barrio,
      @JsonKey(name: 'tarifa_mensual') int tarifaMensual,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      EstadoCliente estado,
      @JsonKey(name: 'fecha_ingreso') DateTime fechaIngreso,
      @JsonKey(name: 'fecha_retiro') DateTime? fechaRetiro,
      @JsonKey(name: 'deuda_inicial') int deudaInicial,
      String? notas,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$ClienteImplCopyWithImpl<$Res>
    extends _$ClienteCopyWithImpl<$Res, _$ClienteImpl>
    implements _$$ClienteImplCopyWith<$Res> {
  __$$ClienteImplCopyWithImpl(
      _$ClienteImpl _value, $Res Function(_$ClienteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? codigo = null,
    Object? cedula = null,
    Object? nombre = null,
    Object? direccion = freezed,
    Object? telefono = freezed,
    Object? sector = freezed,
    Object? zona = freezed,
    Object? barrio = freezed,
    Object? tarifaMensual = null,
    Object? estado = null,
    Object? fechaIngreso = null,
    Object? fechaRetiro = freezed,
    Object? deudaInicial = null,
    Object? notas = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ClienteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as int,
      cedula: null == cedula
          ? _value.cedula
          : cedula // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      telefono: freezed == telefono
          ? _value.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _value.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      zona: freezed == zona
          ? _value.zona
          : zona // ignore: cast_nullable_to_non_nullable
              as String?,
      barrio: freezed == barrio
          ? _value.barrio
          : barrio // ignore: cast_nullable_to_non_nullable
              as String?,
      tarifaMensual: null == tarifaMensual
          ? _value.tarifaMensual
          : tarifaMensual // ignore: cast_nullable_to_non_nullable
              as int,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoCliente,
      fechaIngreso: null == fechaIngreso
          ? _value.fechaIngreso
          : fechaIngreso // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaRetiro: freezed == fechaRetiro
          ? _value.fechaRetiro
          : fechaRetiro // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deudaInicial: null == deudaInicial
          ? _value.deudaInicial
          : deudaInicial // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$ClienteImpl extends _Cliente {
  const _$ClienteImpl(
      {required this.id,
      @JsonKey(name: 'tenant_id') required this.tenantId,
      required this.codigo,
      required this.cedula,
      required this.nombre,
      this.direccion,
      this.telefono,
      this.sector,
      this.zona,
      this.barrio,
      @JsonKey(name: 'tarifa_mensual') required this.tarifaMensual,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      this.estado = EstadoCliente.activo,
      @JsonKey(name: 'fecha_ingreso') required this.fechaIngreso,
      @JsonKey(name: 'fecha_retiro') this.fechaRetiro,
      @JsonKey(name: 'deuda_inicial') this.deudaInicial = 0,
      this.notas,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ClienteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClienteImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  final int codigo;
  @override
  final String cedula;
  @override
  final String nombre;
  @override
  final String? direccion;
  @override
  final String? telefono;
  @override
  final String? sector;
  @override
  final String? zona;
  @override
  final String? barrio;
  @override
  @JsonKey(name: 'tarifa_mensual')
  final int tarifaMensual;
  @override
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  final EstadoCliente estado;
  @override
  @JsonKey(name: 'fecha_ingreso')
  final DateTime fechaIngreso;
  @override
  @JsonKey(name: 'fecha_retiro')
  final DateTime? fechaRetiro;
  @override
  @JsonKey(name: 'deuda_inicial')
  final int deudaInicial;
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
    return 'Cliente(id: $id, tenantId: $tenantId, codigo: $codigo, cedula: $cedula, nombre: $nombre, direccion: $direccion, telefono: $telefono, sector: $sector, zona: $zona, barrio: $barrio, tarifaMensual: $tarifaMensual, estado: $estado, fechaIngreso: $fechaIngreso, fechaRetiro: $fechaRetiro, deudaInicial: $deudaInicial, notas: $notas, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClienteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.cedula, cedula) || other.cedula == cedula) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.sector, sector) || other.sector == sector) &&
            (identical(other.zona, zona) || other.zona == zona) &&
            (identical(other.barrio, barrio) || other.barrio == barrio) &&
            (identical(other.tarifaMensual, tarifaMensual) ||
                other.tarifaMensual == tarifaMensual) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.fechaIngreso, fechaIngreso) ||
                other.fechaIngreso == fechaIngreso) &&
            (identical(other.fechaRetiro, fechaRetiro) ||
                other.fechaRetiro == fechaRetiro) &&
            (identical(other.deudaInicial, deudaInicial) ||
                other.deudaInicial == deudaInicial) &&
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
      codigo,
      cedula,
      nombre,
      direccion,
      telefono,
      sector,
      zona,
      barrio,
      tarifaMensual,
      estado,
      fechaIngreso,
      fechaRetiro,
      deudaInicial,
      notas,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClienteImplCopyWith<_$ClienteImpl> get copyWith =>
      __$$ClienteImplCopyWithImpl<_$ClienteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClienteImplToJson(
      this,
    );
  }
}

abstract class _Cliente extends Cliente {
  const factory _Cliente(
      {required final String id,
      @JsonKey(name: 'tenant_id') required final String tenantId,
      required final int codigo,
      required final String cedula,
      required final String nombre,
      final String? direccion,
      final String? telefono,
      final String? sector,
      final String? zona,
      final String? barrio,
      @JsonKey(name: 'tarifa_mensual') required final int tarifaMensual,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      final EstadoCliente estado,
      @JsonKey(name: 'fecha_ingreso') required final DateTime fechaIngreso,
      @JsonKey(name: 'fecha_retiro') final DateTime? fechaRetiro,
      @JsonKey(name: 'deuda_inicial') final int deudaInicial,
      final String? notas,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$ClienteImpl;
  const _Cliente._() : super._();

  factory _Cliente.fromJson(Map<String, dynamic> json) = _$ClienteImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  int get codigo;
  @override
  String get cedula;
  @override
  String get nombre;
  @override
  String? get direccion;
  @override
  String? get telefono;
  @override
  String? get sector;
  @override
  String? get zona;
  @override
  String? get barrio;
  @override
  @JsonKey(name: 'tarifa_mensual')
  int get tarifaMensual;
  @override
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  EstadoCliente get estado;
  @override
  @JsonKey(name: 'fecha_ingreso')
  DateTime get fechaIngreso;
  @override
  @JsonKey(name: 'fecha_retiro')
  DateTime? get fechaRetiro;
  @override
  @JsonKey(name: 'deuda_inicial')
  int get deudaInicial;
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
  _$$ClienteImplCopyWith<_$ClienteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
