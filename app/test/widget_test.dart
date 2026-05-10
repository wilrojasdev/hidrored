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
}
