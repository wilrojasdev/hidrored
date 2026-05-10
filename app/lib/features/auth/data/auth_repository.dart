import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/perfil.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Envía un correo con el enlace para restablecer la contraseña.
  /// El usuario completa el cambio desde la página web de Supabase.
  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email.trim());
  }

  /// Lee el perfil del usuario logueado (incluye tenant_id).
  /// Lanza si no hay sesion o si no existe perfil.
  Future<Perfil> fetchPerfil() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No hay sesion activa');
    }
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return Perfil.fromJson(data);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});
