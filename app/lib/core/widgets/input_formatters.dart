import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatea en vivo dígitos como pesos colombianos con separador de miles.
/// El usuario tipea "18000" y ve "18.000". El cursor se mantiene al final.
class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter();

  static final _fmt = NumberFormat('#,##0', 'es_CO');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = _fmt.format(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatea cédula colombiana con puntos: "1234567" -> "1.234.567".
class CedulaInputFormatter extends TextInputFormatter {
  CedulaInputFormatter();

  static final _fmt = NumberFormat('#,##0', 'es_CO');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = _fmt.format(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatea celular colombiano (10 dígitos) con espacios: "3001234567" ->
/// "300 123 4567". Si tiene menos dígitos los va agrupando.
class TelefonoInputFormatter extends TextInputFormatter {
  TelefonoInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .padRight(0)
        .substring(
          0,
          newValue.text.replaceAll(RegExp(r'[^0-9]'), '').length.clamp(0, 10),
        );
    if (digits.isEmpty) return const TextEditingValue();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buf.write(' ');
      buf.write(digits[i]);
    }
    final out = buf.toString();
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}
