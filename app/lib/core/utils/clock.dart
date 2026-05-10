/// Reloj fijado a la zona horaria America/Bogota (UTC-5, sin DST).
///
/// Se usa en lugar de `DateTime.now()` en cualquier lógica de negocio
/// sensible al día (cálculo de mora, lista de corte, fecha de retiro,
/// fecha de pago/emisión por defecto) para evitar desfases si el
/// dispositivo o el CI corre en otra zona horaria.
///
/// Pickers de UI siguen usando `DateTime.now()` local — son selecciones
/// del usuario, no cálculos de negocio.
class BogotaClock {
  const BogotaClock._();

  /// Colombia no observa horario de verano: el offset es siempre UTC-5.
  static const Duration _offset = Duration(hours: -5);

  /// Instante actual representado como un `DateTime` cuyos campos
  /// (year/month/day/hour/...) corresponden a la hora de Bogotá.
  /// El objeto es "naive" (sin tz info), apto para formateo y para
  /// derivar el día calendario.
  static DateTime ahora() => DateTime.now().toUtc().add(_offset);

  /// Día actual en Bogotá, como `DateTime` con hora 00:00:00.
  /// Útil para cálculos de "hoy" (mora, corte, etc.).
  static DateTime hoy() {
    final n = ahora();
    return DateTime(n.year, n.month, n.day);
  }

  /// Formato `yyyy-MM-dd` del día de hoy en Bogotá.
  /// Útil para columnas `date` de Postgres.
  static String hoyIso() {
    final h = hoy();
    return '${h.year.toString().padLeft(4, '0')}-'
        '${h.month.toString().padLeft(2, '0')}-'
        '${h.day.toString().padLeft(2, '0')}';
  }
}
