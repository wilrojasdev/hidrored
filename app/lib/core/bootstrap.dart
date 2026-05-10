import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';

Future<void> bootstrap() async {
  // Locale en espanol Colombia para fechas y numeros.
  await initializeDateFormatting('es_CO');

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: kDebugMode,
    );
  } else if (kDebugMode) {
    debugPrint(
      '[hidrored] Supabase no configurado. '
      'Pasa --dart-define=SUPABASE_URL=... y SUPABASE_ANON_KEY=... '
      'al ejecutar para habilitar el backend.',
    );
  }
}
