import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream del estado de conectividad del dispositivo.
///
/// Emite la lista de transportes disponibles (`wifi`, `mobile`,
/// `ethernet`, `none`, etc.). Si la lista contiene solo `none` o está
/// vacía, el dispositivo está sin conexión.
///
/// Nota: detecta la presencia de una red, no si Supabase es alcanzable.
/// Una red WiFi sin internet real reportará "conectado". Si necesitamos
/// detectar esto, en una iteración posterior podemos hacer ping a
/// Supabase health o capturar `SocketException` en cada query y elevar
/// un evento global.
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) => Connectivity().onConnectivityChanged,
);

/// `true` cuando el dispositivo NO tiene ninguna red activa.
/// Mientras se carga el primer evento, asumimos online (false) para no
/// mostrar el banner falsamente al arrancar.
final isOfflineProvider = Provider<bool>((ref) {
  final async = ref.watch(connectivityStreamProvider);
  final list = async.valueOrNull;
  if (list == null || list.isEmpty) return false;
  return list.every((r) => r == ConnectivityResult.none);
});
