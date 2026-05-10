import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Convierte un error técnico (Supabase, red, etc.) en un mensaje
/// apto para mostrar al usuario en una SnackBar/diálogo.
///
/// El error original NO se devuelve aquí: debe loguearse aparte con
/// `appLogger.e(...)` para diagnóstico interno. La idea es no exponer
/// stack traces, URLs internas ni códigos de Supabase a quien usa la app.
String userMessageFor(Object error) {
  if (error is AuthException) {
    return _authMessage(error);
  }
  if (error is PostgrestException) {
    return _postgrestMessage(error);
  }
  if (error is SocketException) {
    return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
  }
  if (error is HttpException || error is HandshakeException) {
    return 'No pudimos comunicarnos con el servidor. Intenta de nuevo en un momento.';
  }
  if (error is FormatException) {
    return 'El archivo o los datos tienen un formato inesperado. Revisa e intenta de nuevo.';
  }
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}

String _authMessage(AuthException e) {
  final msg = e.message.toLowerCase();
  if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
    return 'Correo o contraseña incorrectos.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Tu correo aún no ha sido confirmado. Revisa tu bandeja de entrada.';
  }
  if (msg.contains('user not found')) {
    return 'No encontramos una cuenta con ese correo.';
  }
  if (msg.contains('rate limit') || msg.contains('too many')) {
    return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
  }
  if (msg.contains('network')) {
    return 'Problema de conexión. Verifica tu red e intenta de nuevo.';
  }
  return 'No pudimos iniciar tu sesión. Verifica tus datos e intenta de nuevo.';
}

String _postgrestMessage(PostgrestException e) {
  // 23505 = unique_violation, 23503 = foreign_key_violation
  if (e.code == '23505') {
    return 'Ya existe un registro con esos datos. Revisa el código o cédula '
        'para que no se repita.';
  }
  if (e.code == '23503') {
    return 'No se puede borrar o cambiar este registro porque otros datos '
        'dependen de él (por ejemplo, facturas o pagos asociados).';
  }
  if (e.code == 'PGRST301' || e.code == '42501') {
    return 'No tienes permiso para realizar esta acción. Contacta al '
        'administrador del acueducto.';
  }
  if (e.code == '23502') {
    return 'Faltan datos obligatorios para guardar.';
  }
  if (e.code == '22P02') {
    return 'Uno de los datos tiene un formato incorrecto. Revisa los campos numéricos.';
  }
  return 'Hubo un problema al guardar los datos. Intenta de nuevo.';
}
