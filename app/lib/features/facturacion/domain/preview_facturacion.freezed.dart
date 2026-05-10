// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preview_facturacion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PreviewFacturaCliente {
  Cliente get cliente => throw _privateConstructorUsedError;
  TipoFactura get tipo => throw _privateConstructorUsedError;

  /// Suma de las facturas anteriores pendientes (mensualidades viejas).
  int get totalAtrasos => throw _privateConstructorUsedError;

  /// Cantidad de facturas pendientes anteriores.
  int get cantidadAtrasos => throw _privateConstructorUsedError;

  /// Mensualidad del mes que se esta facturando (0 si suspendido).
  int get valorMensualidad => throw _privateConstructorUsedError;

  /// Mora a cobrar en esta nueva factura (incremental, no doble).
  int get valorMora => throw _privateConstructorUsedError;

  /// Costo de reconexion (solo si suspendido).
  int get costoReconexion => throw _privateConstructorUsedError;

  /// Cargos extra (conceptos) en cola que se aplicarán a esta factura.
  /// Cuando se ejecute la emisión, cada cargo se vuelve una línea de
  /// la factura y se marca como aplicado server-side.
  List<CargoPendiente> get cargosExtras => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PreviewFacturaClienteCopyWith<PreviewFacturaCliente> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreviewFacturaClienteCopyWith<$Res> {
  factory $PreviewFacturaClienteCopyWith(
    PreviewFacturaCliente value,
    $Res Function(PreviewFacturaCliente) then,
  ) = _$PreviewFacturaClienteCopyWithImpl<$Res, PreviewFacturaCliente>;
  @useResult
  $Res call({
    Cliente cliente,
    TipoFactura tipo,
    int totalAtrasos,
    int cantidadAtrasos,
    int valorMensualidad,
    int valorMora,
    int costoReconexion,
    List<CargoPendiente> cargosExtras,
  });

  $ClienteCopyWith<$Res> get cliente;
}

/// @nodoc
class _$PreviewFacturaClienteCopyWithImpl<
  $Res,
  $Val extends PreviewFacturaCliente
>
    implements $PreviewFacturaClienteCopyWith<$Res> {
  _$PreviewFacturaClienteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cliente = null,
    Object? tipo = null,
    Object? totalAtrasos = null,
    Object? cantidadAtrasos = null,
    Object? valorMensualidad = null,
    Object? valorMora = null,
    Object? costoReconexion = null,
    Object? cargosExtras = null,
  }) {
    return _then(
      _value.copyWith(
            cliente: null == cliente
                ? _value.cliente
                : cliente // ignore: cast_nullable_to_non_nullable
                      as Cliente,
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as TipoFactura,
            totalAtrasos: null == totalAtrasos
                ? _value.totalAtrasos
                : totalAtrasos // ignore: cast_nullable_to_non_nullable
                      as int,
            cantidadAtrasos: null == cantidadAtrasos
                ? _value.cantidadAtrasos
                : cantidadAtrasos // ignore: cast_nullable_to_non_nullable
                      as int,
            valorMensualidad: null == valorMensualidad
                ? _value.valorMensualidad
                : valorMensualidad // ignore: cast_nullable_to_non_nullable
                      as int,
            valorMora: null == valorMora
                ? _value.valorMora
                : valorMora // ignore: cast_nullable_to_non_nullable
                      as int,
            costoReconexion: null == costoReconexion
                ? _value.costoReconexion
                : costoReconexion // ignore: cast_nullable_to_non_nullable
                      as int,
            cargosExtras: null == cargosExtras
                ? _value.cargosExtras
                : cargosExtras // ignore: cast_nullable_to_non_nullable
                      as List<CargoPendiente>,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $ClienteCopyWith<$Res> get cliente {
    return $ClienteCopyWith<$Res>(_value.cliente, (value) {
      return _then(_value.copyWith(cliente: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PreviewFacturaClienteImplCopyWith<$Res>
    implements $PreviewFacturaClienteCopyWith<$Res> {
  factory _$$PreviewFacturaClienteImplCopyWith(
    _$PreviewFacturaClienteImpl value,
    $Res Function(_$PreviewFacturaClienteImpl) then,
  ) = __$$PreviewFacturaClienteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Cliente cliente,
    TipoFactura tipo,
    int totalAtrasos,
    int cantidadAtrasos,
    int valorMensualidad,
    int valorMora,
    int costoReconexion,
    List<CargoPendiente> cargosExtras,
  });

  @override
  $ClienteCopyWith<$Res> get cliente;
}

/// @nodoc
class __$$PreviewFacturaClienteImplCopyWithImpl<$Res>
    extends
        _$PreviewFacturaClienteCopyWithImpl<$Res, _$PreviewFacturaClienteImpl>
    implements _$$PreviewFacturaClienteImplCopyWith<$Res> {
  __$$PreviewFacturaClienteImplCopyWithImpl(
    _$PreviewFacturaClienteImpl _value,
    $Res Function(_$PreviewFacturaClienteImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cliente = null,
    Object? tipo = null,
    Object? totalAtrasos = null,
    Object? cantidadAtrasos = null,
    Object? valorMensualidad = null,
    Object? valorMora = null,
    Object? costoReconexion = null,
    Object? cargosExtras = null,
  }) {
    return _then(
      _$PreviewFacturaClienteImpl(
        cliente: null == cliente
            ? _value.cliente
            : cliente // ignore: cast_nullable_to_non_nullable
                  as Cliente,
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as TipoFactura,
        totalAtrasos: null == totalAtrasos
            ? _value.totalAtrasos
            : totalAtrasos // ignore: cast_nullable_to_non_nullable
                  as int,
        cantidadAtrasos: null == cantidadAtrasos
            ? _value.cantidadAtrasos
            : cantidadAtrasos // ignore: cast_nullable_to_non_nullable
                  as int,
        valorMensualidad: null == valorMensualidad
            ? _value.valorMensualidad
            : valorMensualidad // ignore: cast_nullable_to_non_nullable
                  as int,
        valorMora: null == valorMora
            ? _value.valorMora
            : valorMora // ignore: cast_nullable_to_non_nullable
                  as int,
        costoReconexion: null == costoReconexion
            ? _value.costoReconexion
            : costoReconexion // ignore: cast_nullable_to_non_nullable
                  as int,
        cargosExtras: null == cargosExtras
            ? _value._cargosExtras
            : cargosExtras // ignore: cast_nullable_to_non_nullable
                  as List<CargoPendiente>,
      ),
    );
  }
}

/// @nodoc

class _$PreviewFacturaClienteImpl extends _PreviewFacturaCliente {
  const _$PreviewFacturaClienteImpl({
    required this.cliente,
    required this.tipo,
    required this.totalAtrasos,
    required this.cantidadAtrasos,
    required this.valorMensualidad,
    required this.valorMora,
    required this.costoReconexion,
    final List<CargoPendiente> cargosExtras = const <CargoPendiente>[],
  }) : _cargosExtras = cargosExtras,
       super._();

  @override
  final Cliente cliente;
  @override
  final TipoFactura tipo;

  /// Suma de las facturas anteriores pendientes (mensualidades viejas).
  @override
  final int totalAtrasos;

  /// Cantidad de facturas pendientes anteriores.
  @override
  final int cantidadAtrasos;

  /// Mensualidad del mes que se esta facturando (0 si suspendido).
  @override
  final int valorMensualidad;

  /// Mora a cobrar en esta nueva factura (incremental, no doble).
  @override
  final int valorMora;

  /// Costo de reconexion (solo si suspendido).
  @override
  final int costoReconexion;

  /// Cargos extra (conceptos) en cola que se aplicarán a esta factura.
  /// Cuando se ejecute la emisión, cada cargo se vuelve una línea de
  /// la factura y se marca como aplicado server-side.
  final List<CargoPendiente> _cargosExtras;

  /// Cargos extra (conceptos) en cola que se aplicarán a esta factura.
  /// Cuando se ejecute la emisión, cada cargo se vuelve una línea de
  /// la factura y se marca como aplicado server-side.
  @override
  @JsonKey()
  List<CargoPendiente> get cargosExtras {
    if (_cargosExtras is EqualUnmodifiableListView) return _cargosExtras;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cargosExtras);
  }

  @override
  String toString() {
    return 'PreviewFacturaCliente(cliente: $cliente, tipo: $tipo, totalAtrasos: $totalAtrasos, cantidadAtrasos: $cantidadAtrasos, valorMensualidad: $valorMensualidad, valorMora: $valorMora, costoReconexion: $costoReconexion, cargosExtras: $cargosExtras)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreviewFacturaClienteImpl &&
            (identical(other.cliente, cliente) || other.cliente == cliente) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.totalAtrasos, totalAtrasos) ||
                other.totalAtrasos == totalAtrasos) &&
            (identical(other.cantidadAtrasos, cantidadAtrasos) ||
                other.cantidadAtrasos == cantidadAtrasos) &&
            (identical(other.valorMensualidad, valorMensualidad) ||
                other.valorMensualidad == valorMensualidad) &&
            (identical(other.valorMora, valorMora) ||
                other.valorMora == valorMora) &&
            (identical(other.costoReconexion, costoReconexion) ||
                other.costoReconexion == costoReconexion) &&
            const DeepCollectionEquality().equals(
              other._cargosExtras,
              _cargosExtras,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    cliente,
    tipo,
    totalAtrasos,
    cantidadAtrasos,
    valorMensualidad,
    valorMora,
    costoReconexion,
    const DeepCollectionEquality().hash(_cargosExtras),
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreviewFacturaClienteImplCopyWith<_$PreviewFacturaClienteImpl>
  get copyWith =>
      __$$PreviewFacturaClienteImplCopyWithImpl<_$PreviewFacturaClienteImpl>(
        this,
        _$identity,
      );
}

abstract class _PreviewFacturaCliente extends PreviewFacturaCliente {
  const factory _PreviewFacturaCliente({
    required final Cliente cliente,
    required final TipoFactura tipo,
    required final int totalAtrasos,
    required final int cantidadAtrasos,
    required final int valorMensualidad,
    required final int valorMora,
    required final int costoReconexion,
    final List<CargoPendiente> cargosExtras,
  }) = _$PreviewFacturaClienteImpl;
  const _PreviewFacturaCliente._() : super._();

  @override
  Cliente get cliente;
  @override
  TipoFactura get tipo;
  @override
  /// Suma de las facturas anteriores pendientes (mensualidades viejas).
  int get totalAtrasos;
  @override
  /// Cantidad de facturas pendientes anteriores.
  int get cantidadAtrasos;
  @override
  /// Mensualidad del mes que se esta facturando (0 si suspendido).
  int get valorMensualidad;
  @override
  /// Mora a cobrar en esta nueva factura (incremental, no doble).
  int get valorMora;
  @override
  /// Costo de reconexion (solo si suspendido).
  int get costoReconexion;
  @override
  /// Cargos extra (conceptos) en cola que se aplicarán a esta factura.
  /// Cuando se ejecute la emisión, cada cargo se vuelve una línea de
  /// la factura y se marca como aplicado server-side.
  List<CargoPendiente> get cargosExtras;
  @override
  @JsonKey(ignore: true)
  _$$PreviewFacturaClienteImplCopyWith<_$PreviewFacturaClienteImpl>
  get copyWith => throw _privateConstructorUsedError;
}
