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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PreviewFacturaCliente {
  Cliente get cliente => throw _privateConstructorUsedError;
  TipoFactura get tipo => throw _privateConstructorUsedError;

  /// Mensualidad del mes que se esta facturando (0 si suspendido).
  int get valorMensualidad => throw _privateConstructorUsedError;

  /// Mora total a cobrar en esta nueva factura. Calculada como mora
  /// sobre TODAS las sub-deudas pendientes (cada saldo refacturado
  /// arrastra los dias desde su vencimiento ORIGINAL), descontando lo
  /// ya capturado en facturas anteriores.
  int get valorMora => throw _privateConstructorUsedError;

  /// Costo de reconexion (solo si suspendido).
  int get costoReconexion => throw _privateConstructorUsedError;

  /// Cargos extra (conceptos) en cola que se aplicaran como linea de la
  /// factura. Cuando se emita, cada uno queda marcado como aplicado.
  List<CargoPendiente> get cargosExtras => throw _privateConstructorUsedError;

  /// Saldos pendientes anteriores que seran absorbidos en esta factura.
  /// Cada uno se inserta server-side como una linea con
  /// `factura_origen_id` apuntando a su factura origen.
  List<SaldoRefacturado> get lineasRefacturadas =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PreviewFacturaClienteCopyWith<PreviewFacturaCliente> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreviewFacturaClienteCopyWith<$Res> {
  factory $PreviewFacturaClienteCopyWith(PreviewFacturaCliente value,
          $Res Function(PreviewFacturaCliente) then) =
      _$PreviewFacturaClienteCopyWithImpl<$Res, PreviewFacturaCliente>;
  @useResult
  $Res call(
      {Cliente cliente,
      TipoFactura tipo,
      int valorMensualidad,
      int valorMora,
      int costoReconexion,
      List<CargoPendiente> cargosExtras,
      List<SaldoRefacturado> lineasRefacturadas});

  $ClienteCopyWith<$Res> get cliente;
}

/// @nodoc
class _$PreviewFacturaClienteCopyWithImpl<$Res,
        $Val extends PreviewFacturaCliente>
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
    Object? valorMensualidad = null,
    Object? valorMora = null,
    Object? costoReconexion = null,
    Object? cargosExtras = null,
    Object? lineasRefacturadas = null,
  }) {
    return _then(_value.copyWith(
      cliente: null == cliente
          ? _value.cliente
          : cliente // ignore: cast_nullable_to_non_nullable
              as Cliente,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoFactura,
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
      lineasRefacturadas: null == lineasRefacturadas
          ? _value.lineasRefacturadas
          : lineasRefacturadas // ignore: cast_nullable_to_non_nullable
              as List<SaldoRefacturado>,
    ) as $Val);
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
          $Res Function(_$PreviewFacturaClienteImpl) then) =
      __$$PreviewFacturaClienteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Cliente cliente,
      TipoFactura tipo,
      int valorMensualidad,
      int valorMora,
      int costoReconexion,
      List<CargoPendiente> cargosExtras,
      List<SaldoRefacturado> lineasRefacturadas});

  @override
  $ClienteCopyWith<$Res> get cliente;
}

/// @nodoc
class __$$PreviewFacturaClienteImplCopyWithImpl<$Res>
    extends _$PreviewFacturaClienteCopyWithImpl<$Res,
        _$PreviewFacturaClienteImpl>
    implements _$$PreviewFacturaClienteImplCopyWith<$Res> {
  __$$PreviewFacturaClienteImplCopyWithImpl(_$PreviewFacturaClienteImpl _value,
      $Res Function(_$PreviewFacturaClienteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cliente = null,
    Object? tipo = null,
    Object? valorMensualidad = null,
    Object? valorMora = null,
    Object? costoReconexion = null,
    Object? cargosExtras = null,
    Object? lineasRefacturadas = null,
  }) {
    return _then(_$PreviewFacturaClienteImpl(
      cliente: null == cliente
          ? _value.cliente
          : cliente // ignore: cast_nullable_to_non_nullable
              as Cliente,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoFactura,
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
      lineasRefacturadas: null == lineasRefacturadas
          ? _value._lineasRefacturadas
          : lineasRefacturadas // ignore: cast_nullable_to_non_nullable
              as List<SaldoRefacturado>,
    ));
  }
}

/// @nodoc

class _$PreviewFacturaClienteImpl extends _PreviewFacturaCliente {
  const _$PreviewFacturaClienteImpl(
      {required this.cliente,
      required this.tipo,
      required this.valorMensualidad,
      required this.valorMora,
      required this.costoReconexion,
      final List<CargoPendiente> cargosExtras = const <CargoPendiente>[],
      final List<SaldoRefacturado> lineasRefacturadas =
          const <SaldoRefacturado>[]})
      : _cargosExtras = cargosExtras,
        _lineasRefacturadas = lineasRefacturadas,
        super._();

  @override
  final Cliente cliente;
  @override
  final TipoFactura tipo;

  /// Mensualidad del mes que se esta facturando (0 si suspendido).
  @override
  final int valorMensualidad;

  /// Mora total a cobrar en esta nueva factura. Calculada como mora
  /// sobre TODAS las sub-deudas pendientes (cada saldo refacturado
  /// arrastra los dias desde su vencimiento ORIGINAL), descontando lo
  /// ya capturado en facturas anteriores.
  @override
  final int valorMora;

  /// Costo de reconexion (solo si suspendido).
  @override
  final int costoReconexion;

  /// Cargos extra (conceptos) en cola que se aplicaran como linea de la
  /// factura. Cuando se emita, cada uno queda marcado como aplicado.
  final List<CargoPendiente> _cargosExtras;

  /// Cargos extra (conceptos) en cola que se aplicaran como linea de la
  /// factura. Cuando se emita, cada uno queda marcado como aplicado.
  @override
  @JsonKey()
  List<CargoPendiente> get cargosExtras {
    if (_cargosExtras is EqualUnmodifiableListView) return _cargosExtras;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cargosExtras);
  }

  /// Saldos pendientes anteriores que seran absorbidos en esta factura.
  /// Cada uno se inserta server-side como una linea con
  /// `factura_origen_id` apuntando a su factura origen.
  final List<SaldoRefacturado> _lineasRefacturadas;

  /// Saldos pendientes anteriores que seran absorbidos en esta factura.
  /// Cada uno se inserta server-side como una linea con
  /// `factura_origen_id` apuntando a su factura origen.
  @override
  @JsonKey()
  List<SaldoRefacturado> get lineasRefacturadas {
    if (_lineasRefacturadas is EqualUnmodifiableListView)
      return _lineasRefacturadas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lineasRefacturadas);
  }

  @override
  String toString() {
    return 'PreviewFacturaCliente(cliente: $cliente, tipo: $tipo, valorMensualidad: $valorMensualidad, valorMora: $valorMora, costoReconexion: $costoReconexion, cargosExtras: $cargosExtras, lineasRefacturadas: $lineasRefacturadas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreviewFacturaClienteImpl &&
            (identical(other.cliente, cliente) || other.cliente == cliente) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.valorMensualidad, valorMensualidad) ||
                other.valorMensualidad == valorMensualidad) &&
            (identical(other.valorMora, valorMora) ||
                other.valorMora == valorMora) &&
            (identical(other.costoReconexion, costoReconexion) ||
                other.costoReconexion == costoReconexion) &&
            const DeepCollectionEquality()
                .equals(other._cargosExtras, _cargosExtras) &&
            const DeepCollectionEquality()
                .equals(other._lineasRefacturadas, _lineasRefacturadas));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      cliente,
      tipo,
      valorMensualidad,
      valorMora,
      costoReconexion,
      const DeepCollectionEquality().hash(_cargosExtras),
      const DeepCollectionEquality().hash(_lineasRefacturadas));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreviewFacturaClienteImplCopyWith<_$PreviewFacturaClienteImpl>
      get copyWith => __$$PreviewFacturaClienteImplCopyWithImpl<
          _$PreviewFacturaClienteImpl>(this, _$identity);
}

abstract class _PreviewFacturaCliente extends PreviewFacturaCliente {
  const factory _PreviewFacturaCliente(
          {required final Cliente cliente,
          required final TipoFactura tipo,
          required final int valorMensualidad,
          required final int valorMora,
          required final int costoReconexion,
          final List<CargoPendiente> cargosExtras,
          final List<SaldoRefacturado> lineasRefacturadas}) =
      _$PreviewFacturaClienteImpl;
  const _PreviewFacturaCliente._() : super._();

  @override
  Cliente get cliente;
  @override
  TipoFactura get tipo;
  @override

  /// Mensualidad del mes que se esta facturando (0 si suspendido).
  int get valorMensualidad;
  @override

  /// Mora total a cobrar en esta nueva factura. Calculada como mora
  /// sobre TODAS las sub-deudas pendientes (cada saldo refacturado
  /// arrastra los dias desde su vencimiento ORIGINAL), descontando lo
  /// ya capturado en facturas anteriores.
  int get valorMora;
  @override

  /// Costo de reconexion (solo si suspendido).
  int get costoReconexion;
  @override

  /// Cargos extra (conceptos) en cola que se aplicaran como linea de la
  /// factura. Cuando se emita, cada uno queda marcado como aplicado.
  List<CargoPendiente> get cargosExtras;
  @override

  /// Saldos pendientes anteriores que seran absorbidos en esta factura.
  /// Cada uno se inserta server-side como una linea con
  /// `factura_origen_id` apuntando a su factura origen.
  List<SaldoRefacturado> get lineasRefacturadas;
  @override
  @JsonKey(ignore: true)
  _$$PreviewFacturaClienteImplCopyWith<_$PreviewFacturaClienteImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SaldoRefacturado {
  String get facturaOrigenId => throw _privateConstructorUsedError;
  String get numero => throw _privateConstructorUsedError;
  String get periodo => throw _privateConstructorUsedError;
  DateTime get fechaVencimiento => throw _privateConstructorUsedError;

  /// Mora ya facturada en la factura origen (capturada al emitirla).
  /// Sirve para evitar doble cobro al recalcular mora.
  int get moraYaFacturadaEnOrigen => throw _privateConstructorUsedError;

  /// Saldo no pagado: total - sum(pago_factura.monto_aplicado).
  int get saldo => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SaldoRefacturadoCopyWith<SaldoRefacturado> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaldoRefacturadoCopyWith<$Res> {
  factory $SaldoRefacturadoCopyWith(
          SaldoRefacturado value, $Res Function(SaldoRefacturado) then) =
      _$SaldoRefacturadoCopyWithImpl<$Res, SaldoRefacturado>;
  @useResult
  $Res call(
      {String facturaOrigenId,
      String numero,
      String periodo,
      DateTime fechaVencimiento,
      int moraYaFacturadaEnOrigen,
      int saldo});
}

/// @nodoc
class _$SaldoRefacturadoCopyWithImpl<$Res, $Val extends SaldoRefacturado>
    implements $SaldoRefacturadoCopyWith<$Res> {
  _$SaldoRefacturadoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facturaOrigenId = null,
    Object? numero = null,
    Object? periodo = null,
    Object? fechaVencimiento = null,
    Object? moraYaFacturadaEnOrigen = null,
    Object? saldo = null,
  }) {
    return _then(_value.copyWith(
      facturaOrigenId: null == facturaOrigenId
          ? _value.facturaOrigenId
          : facturaOrigenId // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      periodo: null == periodo
          ? _value.periodo
          : periodo // ignore: cast_nullable_to_non_nullable
              as String,
      fechaVencimiento: null == fechaVencimiento
          ? _value.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      moraYaFacturadaEnOrigen: null == moraYaFacturadaEnOrigen
          ? _value.moraYaFacturadaEnOrigen
          : moraYaFacturadaEnOrigen // ignore: cast_nullable_to_non_nullable
              as int,
      saldo: null == saldo
          ? _value.saldo
          : saldo // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaldoRefacturadoImplCopyWith<$Res>
    implements $SaldoRefacturadoCopyWith<$Res> {
  factory _$$SaldoRefacturadoImplCopyWith(_$SaldoRefacturadoImpl value,
          $Res Function(_$SaldoRefacturadoImpl) then) =
      __$$SaldoRefacturadoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String facturaOrigenId,
      String numero,
      String periodo,
      DateTime fechaVencimiento,
      int moraYaFacturadaEnOrigen,
      int saldo});
}

/// @nodoc
class __$$SaldoRefacturadoImplCopyWithImpl<$Res>
    extends _$SaldoRefacturadoCopyWithImpl<$Res, _$SaldoRefacturadoImpl>
    implements _$$SaldoRefacturadoImplCopyWith<$Res> {
  __$$SaldoRefacturadoImplCopyWithImpl(_$SaldoRefacturadoImpl _value,
      $Res Function(_$SaldoRefacturadoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facturaOrigenId = null,
    Object? numero = null,
    Object? periodo = null,
    Object? fechaVencimiento = null,
    Object? moraYaFacturadaEnOrigen = null,
    Object? saldo = null,
  }) {
    return _then(_$SaldoRefacturadoImpl(
      facturaOrigenId: null == facturaOrigenId
          ? _value.facturaOrigenId
          : facturaOrigenId // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      periodo: null == periodo
          ? _value.periodo
          : periodo // ignore: cast_nullable_to_non_nullable
              as String,
      fechaVencimiento: null == fechaVencimiento
          ? _value.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      moraYaFacturadaEnOrigen: null == moraYaFacturadaEnOrigen
          ? _value.moraYaFacturadaEnOrigen
          : moraYaFacturadaEnOrigen // ignore: cast_nullable_to_non_nullable
              as int,
      saldo: null == saldo
          ? _value.saldo
          : saldo // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SaldoRefacturadoImpl implements _SaldoRefacturado {
  const _$SaldoRefacturadoImpl(
      {required this.facturaOrigenId,
      required this.numero,
      required this.periodo,
      required this.fechaVencimiento,
      required this.moraYaFacturadaEnOrigen,
      required this.saldo});

  @override
  final String facturaOrigenId;
  @override
  final String numero;
  @override
  final String periodo;
  @override
  final DateTime fechaVencimiento;

  /// Mora ya facturada en la factura origen (capturada al emitirla).
  /// Sirve para evitar doble cobro al recalcular mora.
  @override
  final int moraYaFacturadaEnOrigen;

  /// Saldo no pagado: total - sum(pago_factura.monto_aplicado).
  @override
  final int saldo;

  @override
  String toString() {
    return 'SaldoRefacturado(facturaOrigenId: $facturaOrigenId, numero: $numero, periodo: $periodo, fechaVencimiento: $fechaVencimiento, moraYaFacturadaEnOrigen: $moraYaFacturadaEnOrigen, saldo: $saldo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaldoRefacturadoImpl &&
            (identical(other.facturaOrigenId, facturaOrigenId) ||
                other.facturaOrigenId == facturaOrigenId) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.periodo, periodo) || other.periodo == periodo) &&
            (identical(other.fechaVencimiento, fechaVencimiento) ||
                other.fechaVencimiento == fechaVencimiento) &&
            (identical(
                    other.moraYaFacturadaEnOrigen, moraYaFacturadaEnOrigen) ||
                other.moraYaFacturadaEnOrigen == moraYaFacturadaEnOrigen) &&
            (identical(other.saldo, saldo) || other.saldo == saldo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, facturaOrigenId, numero, periodo,
      fechaVencimiento, moraYaFacturadaEnOrigen, saldo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaldoRefacturadoImplCopyWith<_$SaldoRefacturadoImpl> get copyWith =>
      __$$SaldoRefacturadoImplCopyWithImpl<_$SaldoRefacturadoImpl>(
          this, _$identity);
}

abstract class _SaldoRefacturado implements SaldoRefacturado {
  const factory _SaldoRefacturado(
      {required final String facturaOrigenId,
      required final String numero,
      required final String periodo,
      required final DateTime fechaVencimiento,
      required final int moraYaFacturadaEnOrigen,
      required final int saldo}) = _$SaldoRefacturadoImpl;

  @override
  String get facturaOrigenId;
  @override
  String get numero;
  @override
  String get periodo;
  @override
  DateTime get fechaVencimiento;
  @override

  /// Mora ya facturada en la factura origen (capturada al emitirla).
  /// Sirve para evitar doble cobro al recalcular mora.
  int get moraYaFacturadaEnOrigen;
  @override

  /// Saldo no pagado: total - sum(pago_factura.monto_aplicado).
  int get saldo;
  @override
  @JsonKey(ignore: true)
  _$$SaldoRefacturadoImplCopyWith<_$SaldoRefacturadoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
