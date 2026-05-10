/// Variables de entorno inyectadas en build con `--dart-define`.
///
/// Ejemplo de ejecucion:
/// ```
/// fvm flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJh... \
///   --dart-define=POWERSYNC_URL=https://xxxx.powersync.journeyapps.com
/// ```
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String powersyncUrl = String.fromEnvironment(
    'POWERSYNC_URL',
    defaultValue: '',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isSyncConfigured => powersyncUrl.isNotEmpty;
}
