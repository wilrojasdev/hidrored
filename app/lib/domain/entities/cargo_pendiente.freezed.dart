// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cargo_pendiente.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CargoPendiente _$CargoPendienteFromJson(Map<String, dynamic> json) {
  return _CargoPendiente.fromJson(json);
}

/// @nodoc
mixin _$CargoPendiente {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenant_id')
  String get tenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cliente_id')
  String get clienteId => throw _privateConstructorUsedError;
  @JsonKey(name: 'concepto_id')
  String? get conceptoId => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  int get cantidad => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_unitario')
  int get valorUnitario => throw _privateConstructorUsedError;
  String? get notas => throw _privateConstructorUsedError;
  @JsonKey(name: 'aplicado_factura_id')
  String? get aplicadoFacturaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'aplicado_at')
  DateTime? get aplicadoAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CargoPendienteCopyWith<CargoPendiente> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CargoPendienteCopyWith<$Res> {
  factory $CargoPendienteCopyWith(
    CargoPendiente value,
    $Res Function(CargoPendiente) then,
  ) = _$CargoPendienteCopyWithImpl<$Res, CargoPendiente>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'cliente_id') String clienteId,
    @JsonKey(name: 'concepto_id') String? conceptoId,
    String descripcion,
    int cantidad,
    @JsonKey(name: 'valor_unitario') int valorUnitario,
    String? notas,
    @JsonKey(name: 'aplicado_factura_id') String? aplicadoFacturaId,
    @JsonKey(name: 'aplicado_at') DateTime? aplicadoAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$CargoPendienteCopyWithImpl<$Res, $Val extends CargoPendiente>
    implements $CargoPendienteCopyWith<$Res> {
  _$CargoPendienteCopyWithImpl(this._value, this._then);

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
    Object? conceptoId = freezed,
    Object? descripcion = null,
    Object? cantidad = null,
    Object? valorUnitario = null,
    Object? notas = freezed,
    Object? aplicadoFacturaId = freezed,
    Object? aplicadoAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            notas: freezed == notas
                ? _value.notas
                : notas // ignore: cast_nullable_to_non_nullable
                      as String?,
            aplicadoFacturaId: freezed == aplicadoFacturaId
                ? _value.aplicadoFacturaId
                : aplicadoFacturaId // ignore: cast_nullable_to_non_nullable
                      as String?,
            aplicadoAt: freezed == aplicadoAt
                ? _value.aplicadoAt
                : aplicadoAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CargoPendienteImplCopyWith<$Res>
    implements $CargoPendienteCopyWith<$Res> {
  factory _$$CargoPendienteImplCopyWith(
    _$CargoPendienteImpl value,
    $Res Function(_$CargoPendienteImpl) then,
  ) = __$$CargoPendienteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tenant_id') String tenantId,
    @JsonKey(name: 'cliente_id') String clienteId,
    @JsonKey(name: 'concepto_id') String? conceptoId,
    String descripcion,
    int cantidad,
    @JsonKey(name: 'valor_unitario') int valorUnitario,
    String? notas,
    @JsonKey(name: 'aplicado_factura_id') String? aplicadoFacturaId,
    @JsonKey(name: 'aplicado_at') DateTime? aplicadoAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$CargoPendienteImplCopyWithImpl<$Res>
    extends _$CargoPendienteCopyWithImpl<$Res, _$CargoPendienteImpl>
    implements _$$CargoPendienteImplCopyWith<$Res> {
  __$$CargoPendienteImplCopyWithImpl(
    _$CargoPendienteImpl _value,
    $Res Function(_$CargoPendienteImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clienteId = null,
    Object? conceptoId = freezed,
    Object? descripcion = null,
    Object? cantidad = null,
    Object? valorUnitario = null,
    Object? notas = freezed,
    Object? aplicadoFacturaId = freezed,
    Object? aplicadoAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$CargoPendienteImpl(
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
        notas: freezed == notas
            ? _value.notas
            : notas // ignore: cast_nullable_to_non_nullable
                  as String?,
        aplicadoFacturaId: freezed == aplicadoFacturaId
            ? _value.aplicadoFacturaId
            : aplicadoFacturaId // ignore: cast_nullable_to_non_nullable
                  as String?,
        aplicadoAt: freezed == aplicadoAt
            ? _value.aplicadoAt
            : aplicadoAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CargoPendienteImpl extends _CargoPendiente {
  const _$CargoPendienteImpl({
    required this.id,
    @JsonKey(name: 'tenant_id') required this.tenantId,
    @JsonKey(name: 'cliente_id') required this.clienteId,
    @JsonKey(name: 'concepto_id') this.conceptoId,
    required this.descripcion,
    this.cantidad = 1,
    @JsonKey(name: 'valor_unitario') required this.valorUnitario,
    this.notas,
    @JsonKey(name: 'aplicado_factura_id') this.aplicadoFacturaId,
    @JsonKey(name: 'aplicado_at') this.aplicadoAt,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : super._();

  factory _$CargoPendienteImpl.fromJson(Map<String, dynamic> json) =>
      _$$CargoPendienteImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tenant_id')
  final String tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  final String clienteId;
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
  final String? notas;
  @override
  @JsonKey(name: 'aplicado_factura_id')
  final String? aplicadoFacturaId;
  @override
  @JsonKey(name: 'aplicado_at')
  final DateTime? aplicadoAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CargoPendiente(id: $id, tenantId: $tenantId, clienteId: $clienteId, conceptoId: $conceptoId, descripcion: $descripcion, cantidad: $cantidad, valorUnitario: $valorUnitario, notas: $notas, aplicadoFacturaId: $aplicadoFacturaId, aplicadoAt: $aplicadoAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CargoPendienteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.clienteId, clienteId) ||
                other.clienteId == clienteId) &&
            (identical(other.conceptoId, conceptoId) ||
                other.conceptoId == conceptoId) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.cantidad, cantidad) ||
                other.cantidad == cantidad) &&
            (identical(other.valorUnitario, valorUnitario) ||
                other.valorUnitario == valorUnitario) &&
            (identical(other.notas, notas) || other.notas == notas) &&
            (identical(other.aplicadoFacturaId, aplicadoFacturaId) ||
                other.aplicadoFacturaId == aplicadoFacturaId) &&
            (identical(other.aplicadoAt, aplicadoAt) ||
                other.aplicadoAt == aplicadoAt) &&
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
    conceptoId,
    descripcion,
    cantidad,
    valorUnitario,
    notas,
    aplicadoFacturaId,
    aplicadoAt,
    createdAt,
    updatedAt,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CargoPendienteImplCopyWith<_$CargoPendienteImpl> get copyWith =>
      __$$CargoPendienteImplCopyWithImpl<_$CargoPendienteImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CargoPendienteImplToJson(this);
  }
}

abstract class _CargoPendiente extends CargoPendiente {
  const factory _CargoPendiente({
    required final String id,
    @JsonKey(name: 'tenant_id') required final String tenantId,
    @JsonKey(name: 'cliente_id') required final String clienteId,
    @JsonKey(name: 'concepto_id') final String? conceptoId,
    required final String descripcion,
    final int cantidad,
    @JsonKey(name: 'valor_unitario') required final int valorUnitario,
    final String? notas,
    @JsonKey(name: 'aplicado_factura_id') final String? aplicadoFacturaId,
    @JsonKey(name: 'aplicado_at') final DateTime? aplicadoAt,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$CargoPendienteImpl;
  const _CargoPendiente._() : super._();

  factory _CargoPendiente.fromJson(Map<String, dynamic> json) =
      _$CargoPendienteImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tenant_id')
  String get tenantId;
  @override
  @JsonKey(name: 'cliente_id')
  String get clienteId;
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
  String? get notas;
  @override
  @JsonKey(name: 'aplicado_factura_id')
  String? get aplicadoFacturaId;
  @override
  @JsonKey(name: 'aplicado_at')
  DateTime? get aplicadoAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$CargoPendienteImplCopyWith<_$CargoPendienteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
