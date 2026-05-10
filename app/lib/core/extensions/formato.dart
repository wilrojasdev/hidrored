import 'package:intl/intl.dart';

/// Formatea valores monetarios en pesos colombianos: 18000 -> "$ 18.000".
/// Usa siempre el simbolo antes (convencion comun en COP).
String formatPesos(num valor) {
  final f = NumberFormat('#,##0', 'es_CO');
  return r'$ '
      '${f.format(valor)}';
}

/// Igual que [formatPesos] pero sin el símbolo. Útil dentro de TextFields
/// donde el `prefixText: '$ '` ya muestra el símbolo.
String formatPesosNoSymbol(num valor) {
  final f = NumberFormat('#,##0', 'es_CO');
  return f.format(valor);
}

/// Quita puntos/espacios/símbolos para extraer el número entero ingresado por
/// el usuario en un campo de moneda. "$ 18.000" -> 18000. Devuelve null si
/// no hay dígitos.
int? parsePesos(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.tryParse(digits);
}

/// Formatea fecha como "30/05/2025".
String formatFecha(DateTime fecha) {
  return DateFormat('dd/MM/yyyy').format(fecha);
}

/// Formatea periodo "2025-05" -> "Mayo 2025".
String formatPeriodo(String periodo) {
  final parts = periodo.split('-');
  if (parts.length != 2) return periodo;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null) return periodo;
  final fecha = DateTime(year, month);
  return DateFormat('MMMM y', 'es_CO').format(fecha);
}

/// Formatea cédula colombiana con separador de miles: 1234567 -> "1.234.567".
/// No agrega dígito de verificación; las cédulas viejas suelen ser sólo
/// dígitos sin guión.
String formatCedula(String cedula) {
  final digits = cedula.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return cedula;
  final n = int.tryParse(digits);
  if (n == null) return cedula;
  return NumberFormat('#,##0', 'es_CO').format(n);
}

/// Formatea teléfono celular colombiano (10 dígitos) como "300 123 4567".
String formatTelefono(String telefono) {
  final digits = telefono.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 10) {
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }
  if (digits.length == 7) {
    return '${digits.substring(0, 3)} ${digits.substring(3)}';
  }
  return telefono;
}

/// Pluralización simple para textos comunes en español.
/// `pluralES(1, 'cliente', 'clientes')` -> "1 cliente"
/// `pluralES(3, 'cliente', 'clientes')` -> "3 clientes"
String pluralES(int n, String singular, String plural) {
  return '$n ${n == 1 ? singular : plural}';
}
