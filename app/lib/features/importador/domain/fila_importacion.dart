/// Una fila parseada del Excel, con sus errores de validacion (si hay).
class FilaImportacion {
  FilaImportacion({
    required this.indiceFila,
    this.codigo,
    this.cedula,
    this.nombre,
    this.direccion,
    this.telefono,
    this.sector,
    this.zona,
    this.barrio,
    this.tarifa,
    this.deudaInicial,
    this.notas,
    List<String>? errores,
  }) : errores = errores ?? [];

  /// Numero de fila en el Excel original (1-based, sin contar encabezado).
  final int indiceFila;
  int? codigo;
  String? cedula;
  String? nombre;
  String? direccion;
  String? telefono;
  String? sector;
  String? zona;
  String? barrio;
  int? tarifa;
  int? deudaInicial;
  String? notas;

  /// Errores de validacion. Si hay alguno, no se importa.
  final List<String> errores;

  bool get esValida => errores.isEmpty;
}
