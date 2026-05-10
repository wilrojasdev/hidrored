import 'package:freezed_annotation/freezed_annotation.dart';

part 'concepto.freezed.dart';
part 'concepto.g.dart';

/// Concepto del catalogo (cargo extra que el admin puede asignar a una
/// factura: reconexion, mejora de tuberia, multa, etc.)
@freezed
class Concepto with _$Concepto {
  const factory Concepto({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String nombre,
    @JsonKey(name: 'valor_default') @Default(0) int valorDefault,
    String? descripcion,
    @Default(true) bool activo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Concepto;

  factory Concepto.fromJson(Map<String, dynamic> json) =>
      _$ConceptoFromJson(json);
}
