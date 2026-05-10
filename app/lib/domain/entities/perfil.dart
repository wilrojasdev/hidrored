import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil.freezed.dart';
part 'perfil.g.dart';

/// Perfil del admin logueado, con su tenant_id resuelto.
/// Corresponde a la tabla `profiles` en Supabase.
@freezed
class Perfil with _$Perfil {
  const factory Perfil({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String nombre,
    required String email,
    @Default('admin') String rol,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Perfil;

  factory Perfil.fromJson(Map<String, dynamic> json) => _$PerfilFromJson(json);
}
