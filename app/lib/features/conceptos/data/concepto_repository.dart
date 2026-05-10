import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/concepto.dart';
import '../../../domain/entities/perfil.dart';
import '../../auth/presentation/auth_controller.dart';

class ConceptoRepository {
  ConceptoRepository({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<List<Concepto>> list({bool soloActivos = false}) async {
    var query = _client.from('conceptos').select().eq('tenant_id', _tenantId);
    if (soloActivos) {
      query = query.eq('activo', true);
    }
    final data = await query.order('nombre');
    return (data as List)
        .map((row) => Concepto.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Concepto> get(String id) async {
    final data = await _client
        .from('conceptos')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .single();
    return Concepto.fromJson(data);
  }

  Future<Concepto> create({
    required String nombre,
    int valorDefault = 0,
    String? descripcion,
  }) async {
    final data = await _client
        .from('conceptos')
        .insert({
          'tenant_id': _tenantId,
          'nombre': nombre,
          'valor_default': valorDefault,
          'descripcion': descripcion,
          'activo': true,
        })
        .select()
        .single();
    return Concepto.fromJson(data);
  }

  Future<Concepto> update(
    String id, {
    String? nombre,
    int? valorDefault,
    String? descripcion,
    bool? activo,
  }) async {
    final patch = <String, dynamic>{
      if (nombre != null) 'nombre': nombre,
      if (valorDefault != null) 'valor_default': valorDefault,
      'descripcion': descripcion,
      if (activo != null) 'activo': activo,
    };
    final data = await _client
        .from('conceptos')
        .update(patch)
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .select()
        .single();
    return Concepto.fromJson(data);
  }

  Future<void> toggleActivo(String id, bool activo) async {
    await _client
        .from('conceptos')
        .update({'activo': activo})
        .eq('tenant_id', _tenantId)
        .eq('id', id);
  }
}

final conceptoRepositoryProvider = Provider<ConceptoRepository>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return ConceptoRepository(client: client, perfil: perfil);
});
