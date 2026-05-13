import 'package:flutter_test/flutter_test.dart';
import 'package:hidrored/core/extensions/formato.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_CO');
  });

  test('formatPesos: sin decimales y con separador de miles', () {
    expect(formatPesos(18000), r'$ 18.000');
    expect(formatPesos(0), r'$ 0');
    expect(formatPesos(1234567), r'$ 1.234.567');
  });

  test('formatPeriodo: 2025-05 -> mayo 2025', () {
    expect(formatPeriodo('2025-05').toLowerCase(), 'mayo 2025');
  });

  test('formatFecha: dd/MM/yyyy', () {
    expect(formatFecha(DateTime(2025, 5, 30)), '30/05/2025');
  });

  test('formatFechaLarga: mes y año en español', () {
    final s = formatFechaLarga(DateTime(2025, 3, 25));
    expect(s[0], s[0].toLowerCase());
    expect(s.toLowerCase(), contains('marzo'));
    expect(s, contains('2025'));
    expect(s, contains('25'));
  });

  test('formatFechaLargaHora: hora en 12 h con minutos (no 24 h)', () {
    final fecha = DateTime(2025, 3, 25);
    // Tarde: en 24 h sería 15:09; en 12 h debe ser 3:09 (con sufijo de mediodía).
    final reg = DateTime(2025, 3, 25, 15, 9);
    final full = formatFechaLargaHora(fecha, horaRegistro: reg);
    expect(full.toLowerCase(), contains('marzo'));
    expect(full, contains(','));
    expect(full, isNot(contains('15:09')));
    expect(
      RegExp(r'[, ]\s*0?3:09').hasMatch(full),
      isTrue,
      reason: 'Se esperaba hora tipo 3:09 en 12 h, se obtuvo: $full',
    );
  });
}
