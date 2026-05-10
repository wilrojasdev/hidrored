import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/perfil.dart';
import '../data/auth_repository.dart';

/// Provider del perfil del usuario logueado.
/// `null` cuando no hay sesion. AsyncValue para manejar loading/error.
final perfilProvider = FutureProvider<Perfil?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final repo = ref.watch(authRepositoryProvider);
  return repo.fetchPerfil();
});

/// Indica si el usuario esta autenticado y con perfil cargado.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  return perfil != null;
});

/// Controlador del flujo de login. Expone signIn y signOut.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password);
      // Forzar refetch del perfil tras login.
      _ref.invalidate(perfilProvider);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref.read(authRepositoryProvider).signOut();
      _ref.invalidate(perfilProvider);
    });
  }

  /// Solicita un correo de restablecimiento de contraseña. No cambia el
  /// estado de auth (el reset ocurre fuera de la app, vía link en email).
  Future<void> resetPassword(String email) {
    return _ref.read(authRepositoryProvider).resetPassword(email);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
