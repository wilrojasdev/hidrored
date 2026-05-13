// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'factura.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Factura _$FacturaFromJson(Map<String, dynamic> json) {
  return _Factura.fromJson(json);
}

/// @nodoc
mixin _$Factura {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cliente_id')
  String get clienteId => throw _privateConstructorUsedError;
  String get numero => throw _privateConstructorUsedError;
  String get periodo => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
  TipoFactura get tipo => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_emision')
  DateTime get fechaEmision => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_vencimiento')
  DateTime get fechaVencimiento => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_mensualidad')
  int get valorMensualidad => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_mora')
  int get valorMora => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  EstadoFactura get estado => throw _privateConstructorUsedError;
  @JsonKey(name: 'motivo_anulacion')
  String? get motivoAnulacion => throw _privateConstructorUsedError;
  @JsonKey(name: 'refacturada_en_id')
  String? get refacturadaEnId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FacturaCopyWith<Factura> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacturaCopyWith<$Res> {
  factory $FacturaCopyWith(Factura value, $Res Function(Factura) then) =
      _$FacturaCopyWithImpl<$Res, Factura>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      @JsonKey(name: 'cliente_id') String clienteId,
      String numero,
      String periodo,
      @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson) TipoFactura tipo,
      @JsonKey(name: 'fecha_emision') DateTime fechaEmision,
      @JsonKey(name: 'fecha_vencimiento') DateTime fechaVencimiento,
      @JsonKey(name: 'valor_mensualidad') int valorMensualidad,
      @JsonKey(name: 'valor_mora') int valorMora,
      int total,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      EstadoFactura estado,
      @JsonKey(name: 'motivo_anulacion') String? motivoAnulacion,
      @JsonKey(name: 'refacturada_en_id') String? refacturadaEnId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$FacturaCopyWithImpl<$Res, $Val extends Factura>
    implements $FacturaCopyWith<$Res> {
  _$FacturaCopyWithImpl(this._value, this._then);

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
    Object? numero = null,
    Object? periodo = null,
    Object? tipo = null,
    Object? fechaEmision = null,
    Object? fechaVencimiento = null,
    Object? valorMensualidad = null,
    Object? valorMora = null,
    Object? total = null,
    Object? estado = null,
    Object? motivoAnulacion = freezed,
    Object? refacturadaEnId = freezed,
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
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      periodo: null == periodo
          ? _value.periodo
          : periodo // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoFactura,
      fechaEmision: null == fechaEmision
          ? _value.fechaEmision
          : fechaEmision // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaVencimiento: null == fechaVencimiento
          ? _value.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      valorMensualidad: null == valorMensualidad
          ? _value.valorMensualidad
          : valorMensualidad // ignore: cast_nullable_to_non_nullable
              as int,
      valorMora: null == valorMora
          ? _value.valorMora
          : valorMora // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoFactura,
      motivoAnulacion: freezed == motivoAnulacion
          ? _value.motivoAnulacion
          : motivoAnulacion // ignore: cast_nullable_to_non_nullable
              as String?,
      refacturadaEnId: freezed == refacturadaEnId
          ? _value.refacturadaEnId
          : refacturadaEnId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$FacturaImplCopyWith<$Res> implements $FacturaCopyWith<$Res> {
  factory _$$FacturaImplCopyWith(
          _$FacturaImpl value, $Res Function(_$FacturaImpl) then) =
      __$$FacturaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tenant_id') String tenantId,
      @JsonKey(name: 'cliente_id') String clienteId,
      String numero,
      String periodo,
      @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson) TipoFactura tipo,
      @JsonKey(name: 'fecha_emision') DateTime fechaEmision,
      @JsonKey(name: 'fecha_vencimiento') DateTime fechaVencimiento,
      @JsonKey(name: 'valor_mensualidad') int valorMensualidad,
      @JsonKey(name: 'valor_mora') int valorMora,
      int total,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      EstadoFactura estado,
      @JsonKey(name: 'motivo_anulacion') String? motivoAnulacion,
      @JsonKey(name: 'refacturada_en_id') String? refacturadaEnId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$FacturaImplCopyWithImpl<$Res>
    extends _$FacturaCopyWithImpl<$Res, _$FacturaImpl>
    implements _$$FacturaImplCopyWith<$Res> {
  __$$FacturaImplCopyWithImpl(
      _$FacturaImpl _value, $Res Function(_$FacturaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clienteId = null,
    Object? numero = null,
    Object? periodo = null,
    Object? tipo = null,
    Object? fechaEmision = null,
    Object? fechaVencimiento = null,
    Object? valorMensualidad = null,
    Object? valorMora = null,
    Object? total = null,
    Object? estado = null,
    Object? motivoAnulacion = freezed,
    Object? refacturadaEnId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$FacturaImpl(
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
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      periodo: null == periodo
          ? _value.periodo
          : periodo // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoFactura,
      fechaEmision: null == fechaEmision
          ? _value.fechaEmision
          : fechaEmision // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaVencimiento: null == fechaVencimiento
          ? _value.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      valorMensualidad: null == valorMensualidad
          ? _value.valorMensualidad
          : valorMensualidad // ignore: cast_nullable_to_non_nullable
              as int,
      valorMora: null == valorMora
          ? _value.valorMora
          : valorMora // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoFactura,
      motivoAnulacion: freezed == motivoAnulacion
          ? _value.motivoAnulacion
          : motivoAnulacion // ignore: cast_nullable_to_non_nullable
              as String?,
      refacturadaEnId: freezed == refacturadaEnId
          ? _value.refacturadaEnId
          : refacturadaEnId // ignore: cast_nullable_to_non_nullable
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
class _$FacturaImpl extends _Factura {
  const _$FacturaImpl(
      {required this.id,
      @JsonKey(name: 'tenant_id') required this.tenantId,
      @JsonKey(name: 'cliente_id') required this.clienteId,
      required this.numero,
      required this.periodo,
      @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
      this.tipo = TipoFactura.mensual,
      @JsonKey(name: 'fecha_emision') required this.fechaEmision,
      @JsonKey(name: 'fecha_vencimiento') required this.fechaVencimiento,
      @JsonKey(name: 'valor_mensualidad') this.valorMensualidad = 0,
      @JsonKey(name: 'valor_mora') this.valorMora = 0,
      required this.total,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      this.estado = EstadoFactura.pendiente,
      @JsonKey(name: 'motivo_anulacion') this.motivoAnulacion,
      @JsonKey(name: 'refacturada_en_id') this.refacturadaEnId,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$FacturaImpl.fromJson(Map<String, dynamic> json) =>
      _$$FacturaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  final String clienteId;
  @override
  final String numero;
  @override
  final String periodo;
  @override
  @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
  final TipoFactura tipo;
  @override
  @JsonKey(name: 'fecha_emision')
  final DateTime fechaEmision;
  @override
  @JsonKey(name: 'fecha_vencimiento')
  final DateTime fechaVencimiento;
  @override
  @JsonKey(name: 'valor_mensualidad')
  final int valorMensualidad;
  @override
  @JsonKey(name: 'valor_mora')
  final int valorMora;
  @override
  final int total;
  @override
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  final EstadoFactura estado;
  @override
  @JsonKey(name: 'motivo_anulacion')
  final String? motivoAnulacion;
  @override
  @JsonKey(name: 'refacturada_en_id')
  final String? refacturadaEnId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Factura(id: $id, tenantId: $tenantId, clienteId: $clienteId, numero: $numero, periodo: $periodo, tipo: $tipo, fechaEmision: $fechaEmision, fechaVencimiento: $fechaVencimiento, valorMensualidad: $valorMensualidad, valorMora: $valorMora, total: $total, estado: $estado, motivoAnulacion: $motivoAnulacion, refacturadaEnId: $refacturadaEnId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacturaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.clienteId, clienteId) ||
                other.clienteId == clienteId) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.periodo, periodo) || other.periodo == periodo) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.fechaEmision, fechaEmision) ||
                other.fechaEmision == fechaEmision) &&
            (identical(other.fechaVencimiento, fechaVencimiento) ||
                other.fechaVencimiento == fechaVencimiento) &&
            (identical(other.valorMensualidad, valorMensualidad) ||
                other.valorMensualidad == valorMensualidad) &&
            (identical(other.valorMora, valorMora) ||
                other.valorMora == valorMora) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.motivoAnulacion, motivoAnulacion) ||
                other.motivoAnulacion == motivoAnulacion) &&
            (identical(other.refacturadaEnId, refacturadaEnId) ||
                other.refacturadaEnId == refacturadaEnId) &&
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
      numero,
      periodo,
      tipo,
      fechaEmision,
      fechaVencimiento,
      valorMensualidad,
      valorMora,
      total,
      estado,
      motivoAnulacion,
      refacturadaEnId,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FacturaImplCopyWith<_$FacturaImpl> get copyWith =>
      __$$FacturaImplCopyWithImpl<_$FacturaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FacturaImplToJson(
      this,
    );
  }
}

abstract class _Factura extends Factura {
  const factory _Factura(
      {required final String id,
      @JsonKey(name: 'tenant_id') required final String tenantId,
      @JsonKey(name: 'cliente_id') required final String clienteId,
      required final String numero,
      required final String periodo,
      @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
      final TipoFactura tipo,
      @JsonKey(name: 'fecha_emision') required final DateTime fechaEmision,
      @JsonKey(name: 'fecha_vencimiento')
      required final DateTime fechaVencimiento,
      @JsonKey(name: 'valor_mensualidad') final int valorMensualidad,
      @JsonKey(name: 'valor_mora') final int valorMora,
      required final int total,
      @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
      final EstadoFactura estado,
      @JsonKey(name: 'motivo_anulacion') final String? motivoAnulacion,
      @JsonKey(name: 'refacturada_en_id') final String? refacturadaEnId,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$FacturaImpl;
  const _Factura._() : super._();

  factory _Factura.fromJson(Map<String, dynamic> json) = _$FacturaImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  String get clienteId;
  @override
  String get numero;
  @override
  String get periodo;
  @override
  @JsonKey(fromJson: _tipoFromJson, toJson: _tipoToJson)
  TipoFactura get tipo;
  @override
  @JsonKey(name: 'fecha_emision')
  DateTime get fechaEmision;
  @override
  @JsonKey(name: 'fecha_vencimiento')
  DateTime get fechaVencimiento;
  @override
  @JsonKey(name: 'valor_mensualidad')
  int get valorMensualidad;
  @override
  @JsonKey(name: 'valor_mora')
  int get valorMora;
  @override
  int get total;
  @override
  @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
  EstadoFactura get estado;
  @override
  @JsonKey(name: 'motivo_anulacion')
  String? get motivoAnulacion;
  @override
  @JsonKey(name: 'refacturada_en_id')
  String? get refacturadaEnId;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FacturaImplCopyWith<_$FacturaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
