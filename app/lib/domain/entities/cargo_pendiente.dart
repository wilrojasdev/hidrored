import 'package:freezed_annotation/freezed_annotation.dart';

part 'cargo_pendiente.freezed.dart';
part 'cargo_pendiente.g.dart';

/// Cargo extra (concepto del catálogo) asignado a un cliente que se
/// incluirá automáticamente como línea en su próximo recibo emitido.
///
/// Mientras `aplicadoFacturaId` sea null, el cargo está "en cola".
/// Cuando se emite la factura del cliente, ese campo apunta a la factura
/// correspondiente. Si la factura se anula, el campo vuelve a null
/// (server-side, vía RPC `anular_factura`) para que el cargo reaparezca
/// en la re-emisión.
@freezed
class CargoPendiente with _$CargoPendiente {
  const CargoPendiente._();

  const factory CargoPendiente({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'cliente_id') required String clienteId,
    @JsonKey(name: 'concepto_id') String? conceptoId,
    required String descripcion,
    @Default(1) int cantidad,
    @JsonKey(name: 'valor_unitario') required int valorUnitario,
    String? notas,
    @JsonKey(name: 'aplicado_factura_id') String? aplicadoFacturaId,
    @JsonKey(name: 'aplicado_at') DateTime? aplicadoAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CargoPendiente;

  factory CargoPendiente.fromJson(Map<String, dynamic> json) =>
      _$CargoPendienteFromJson(json);

  /// Subtotal precalculado (cantidad × valor unitario).
  int get subtotal => cantidad * valorUnitario;

  /// Si el cargo aún está en cola (no se ha aplicado a una factura).
  bool get pendiente => aplicadoFacturaId == null;
}
