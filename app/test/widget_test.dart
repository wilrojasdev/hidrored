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

  test('formatFechaLargaHora: hora 12 h Colombia (mediodía y medianoche)', () {
    final fecha = DateTime(2025, 3, 25);
    final base = formatFechaLarga(fecha);
    expect(
      formatFechaLargaHora(fecha, horaRegistro: DateTime(2025, 3, 25, 15, 9)),
      '$base, 3:09 p. m.',
    );
    expect(
      formatFechaLargaHora(fecha, horaRegistro: DateTime(2025, 3, 25, 9, 7)),
      '$base, 9:07 a. m.',
    );
    expect(
      formatFechaLargaHora(fecha, horaRegistro: DateTime(2025, 3, 25, 0, 5)),
      '$base, 12:05 a. m.',
    );
    expect(
      formatFechaLargaHora(fecha, horaRegistro: DateTime(2025, 3, 25, 12, 0)),
      '$base, 12:00 p. m.',
    );
  });
}
