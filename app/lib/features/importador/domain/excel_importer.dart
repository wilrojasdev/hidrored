import 'dart:typed_data';

import 'package:excel/excel.dart';

import 'fila_importacion.dart';

/// Lee un archivo Excel y produce FilaImportacion validables.
///
/// Formato esperado (fila 1 = encabezado, exactamente estos nombres):
///   codigo | cedula | nombre | direccion | telefono | sector | zona |
///   barrio | tarifa | deuda_inicial | notas
///
/// Las columnas opcionales (direccion, telefono, sector, zona, barrio,
/// notas) pueden quedar vacias. Las obligatorias son cedula, nombre y
/// tarifa. Si codigo viene vacio, se asigna consecutivo automaticamente.
class ExcelImporter {
  const ExcelImporter._();

  static const columnasEsperadas = <String>[
    'codigo',
    'cedula',
    'nombre',
    'direccion',
    'telefono',
    'sector',
    'zona',
    'barrio',
    'tarifa',
    'deuda_inicial',
    'notas',
  ];

  /// Parsea el Excel. Lanza si el formato no es valido. No valida contra
  /// datos existentes (eso lo hace `validar` por separado).
  static List<FilaImportacion> parsear(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      throw const FormatException('El archivo no contiene hojas.');
    }
    final hoja = excel.tables.values.first;
    if (hoja.maxRows < 2) {
      throw const FormatException('El archivo está vacío.');
    }

    final headers = hoja.row(0).map((c) => _toText(c?.value)).toList();
    final mapeo = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      final h = headers[i].toLowerCase().trim();
      if (h.isNotEmpty) mapeo[h] = i;
    }

    // Validar columnas obligatorias.
    const obligatorias = {'cedula', 'nombre', 'tarifa'};
    final faltantes = obligatorias.where((c) => !mapeo.containsKey(c)).toList();
    if (faltantes.isNotEmpty) {
      throw FormatException(
        'Faltan columnas obligatorias: ${faltantes.join(", ")}. '
        'El archivo debe tener encabezado: ${columnasEsperadas.join(", ")}',
      );
    }

    final filas = <FilaImportacion>[];
    for (var r = 1; r < hoja.maxRows; r++) {
      final raw = hoja.row(r);
      if (raw.every((c) => _toText(c?.value).isEmpty)) continue; // fila vacia
      filas.add(
        FilaImportacion(
          indiceFila: r,
          codigo: _intCell(raw, mapeo, 'codigo'),
          cedula: _strCell(raw, mapeo, 'cedula'),
          nombre: _strCell(raw, mapeo, 'nombre'),
          direccion: _strCell(raw, mapeo, 'direccion'),
          telefono: _strCell(raw, mapeo, 'telefono'),
          sector: _strCell(raw, mapeo, 'sector'),
          zona: _strCell(raw, mapeo, 'zona'),
          barrio: _strCell(raw, mapeo, 'barrio'),
          tarifa: _intCell(raw, mapeo, 'tarifa'),
          deudaInicial: _intCell(raw, mapeo, 'deuda_inicial') ?? 0,
          notas: _strCell(raw, mapeo, 'notas'),
        ),
      );
    }
    return filas;
  }

  /// Valida las filas y agrega errores. Asigna codigo automatico si falta.
  /// `codigosExistentes`: codigos de clientes ya en BD (para detectar
  /// colisiones).
  static void validar(
    List<FilaImportacion> filas, {
    required Set<int> codigosExistentes,
    required int siguienteCodigoLibre,
  }) {
    final codigosUsadosEnArchivo = <int>{};
    var siguiente = siguienteCodigoLibre;

    for (final f in filas) {
      f.errores.clear();

      if (f.cedula == null || f.cedula!.trim().isEmpty) {
        f.errores.add('Cédula obligatoria');
      }
      if (f.nombre == null || f.nombre!.trim().isEmpty) {
        f.errores.add('Nombre obligatorio');
      }
      if (f.tarifa == null) {
        f.errores.add('Tarifa obligatoria');
      } else if (f.tarifa! < 0) {
        f.errores.add('Tarifa no puede ser negativa');
      }
      if (f.deudaInicial != null && f.deudaInicial! < 0) {
        f.errores.add('Deuda inicial no puede ser negativa');
      }

      if (f.codigo == null) {
        // Auto-asignar consecutivo evitando colisiones.
        while (codigosExistentes.contains(siguiente) ||
            codigosUsadosEnArchivo.contains(siguiente)) {
          siguiente++;
        }
        f.codigo = siguiente;
        codigosUsadosEnArchivo.add(siguiente);
        siguiente++;
      } else {
        if (codigosExistentes.contains(f.codigo)) {
          f.errores.add('El código ${f.codigo} ya existe en la base');
        } else if (codigosUsadosEnArchivo.contains(f.codigo)) {
          f.errores.add('El código ${f.codigo} se repite en el archivo');
        } else {
          codigosUsadosEnArchivo.add(f.codigo!);
        }
      }
    }
  }

  // ---------- helpers de celdas ----------

  static String _toText(dynamic value) {
    if (value == null) return '';
    if (value is TextCellValue) return value.value.text ?? '';
    if (value is IntCellValue) return '${value.value}';
    if (value is DoubleCellValue) return '${value.value}';
    if (value is BoolCellValue) return '${value.value}';
    if (value is FormulaCellValue) return value.formula;
    return '$value';
  }

  static String? _strCell(List<Data?> raw, Map<String, int> mapeo, String col) {
    final i = mapeo[col];
    if (i == null) return null;
    if (i >= raw.length) return null;
    final t = _toText(raw[i]?.value).trim();
    return t.isEmpty ? null : t;
  }

  static int? _intCell(List<Data?> raw, Map<String, int> mapeo, String col) {
    final i = mapeo[col];
    if (i == null) return null;
    if (i >= raw.length) return null;
    final v = raw[i]?.value;
    if (v == null) return null;
    if (v is IntCellValue) return v.value;
    if (v is DoubleCellValue) return v.value.round();
    final t = _toText(v).replaceAll(RegExp(r'[^\d-]'), '');
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }
}
