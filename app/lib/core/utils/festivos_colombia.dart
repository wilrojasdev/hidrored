// Calculo de festivos colombianos (Ley Emiliani aplicada).
// Replica el algoritmo de la migracion SQL para operacion offline.

class FestivosColombia {
  const FestivosColombia._();

  /// Devuelve todos los festivos del anio dado.
  static List<DateTime> festivosDelAnio(int year) {
    final pascua = _easterDate(year);
    return [
      // Fijos
      DateTime(year, 1, 1),
      DateTime(year, 5, 1),
      DateTime(year, 7, 20),
      DateTime(year, 8, 7),
      DateTime(year, 12, 8),
      DateTime(year, 12, 25),
      // Moviles a lunes (Ley Emiliani)
      _nextMonday(DateTime(year, 1, 6)),
      _nextMonday(DateTime(year, 3, 19)),
      _nextMonday(DateTime(year, 6, 29)),
      _nextMonday(DateTime(year, 8, 15)),
      _nextMonday(DateTime(year, 10, 12)),
      _nextMonday(DateTime(year, 11, 1)),
      _nextMonday(DateTime(year, 11, 11)),
      // Semana Santa (no se mueven)
      pascua.subtract(const Duration(days: 3)),
      pascua.subtract(const Duration(days: 2)),
      // Moviles desde Pascua, llevados a lunes
      _nextMonday(pascua.add(const Duration(days: 39))),
      _nextMonday(pascua.add(const Duration(days: 60))),
      _nextMonday(pascua.add(const Duration(days: 68))),
    ];
  }

  /// True si la fecha es festivo colombiano.
  static bool esFestivo(DateTime fecha) {
    final lista = festivosDelAnio(fecha.year);
    return lista.any((f) => _sameDate(f, fecha));
  }

  /// True si la fecha es dia habil (lun-vie y no festivo).
  static bool esDiaHabil(DateTime fecha) {
    final dow = fecha.weekday; // 1=Mon ... 7=Sun
    if (dow >= DateTime.saturday) return false;
    return !esFestivo(fecha);
  }

  /// Suma N dias habiles a una fecha.
  static DateTime sumarDiasHabiles(DateTime fecha, int dias) {
    var cursor = DateTime(fecha.year, fecha.month, fecha.day);
    var contados = 0;
    while (contados < dias) {
      cursor = cursor.add(const Duration(days: 1));
      if (esDiaHabil(cursor)) contados++;
    }
    return cursor;
  }

  // -------- privados --------

  /// Calcula la fecha de Pascua (Domingo de Resurreccion) por algoritmo de Gauss.
  static DateTime _easterDate(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final mes = (h + l - 7 * m + 114) ~/ 31;
    final dia = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, mes, dia);
  }

  static DateTime _nextMonday(DateTime d) {
    if (d.weekday == DateTime.monday) return d;
    if (d.weekday == DateTime.sunday) return d.add(const Duration(days: 1));
    return d.add(Duration(days: 8 - d.weekday));
  }

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
