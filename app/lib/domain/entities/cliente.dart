import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'cliente.freezed.dart';
part 'cliente.g.dart';

@freezed
class Cliente with _$Cliente {
  const Cliente._();

  const factory Cliente({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required int codigo,
    required String cedula,
    required String nombre,
    String? direccion,
    String? telefono,
    String? sector,
    String? zona,
    String? barrio,
    @JsonKey(name: 'tarifa_mensual') required int tarifaMensual,
    @JsonKey(fromJson: _estadoFromJson, toJson: _estadoToJson)
    @Default(EstadoCliente.activo)
    EstadoCliente estado,
    @JsonKey(name: 'fecha_ingreso') required DateTime fechaIngreso,
    @JsonKey(name: 'fecha_retiro') DateTime? fechaRetiro,
    @JsonKey(name: 'deuda_inicial') @Default(0) int deudaInicial,
    String? notas,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Cliente;

  factory Cliente.fromJson(Map<String, dynamic> json) =>
      _$ClienteFromJson(json);

  bool get tieneServicio => estado.tieneServicio;
}

EstadoCliente _estadoFromJson(String value) => EstadoCliente.fromValue(value);
String _estadoToJson(EstadoCliente estado) => estado.value;
