import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../domain/entities/dano.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

class DanoRepository {
  DanoRepository({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<List<Dano>> list({String? clienteId, EstadoDano? estado}) async {
    var query = _client.from('danos').select().eq('tenant_id', _tenantId);
    if (clienteId != null) query = query.eq('cliente_id', clienteId);
    if (estado != null) query = query.eq('estado', estado.value);
    final data = await query.order('fecha_reporte', ascending: false);
    return (data as List)
        .map((row) => Dano.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Dano> get(String id) async {
    final data = await _client
        .from('danos')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .single();
    return Dano.fromJson(data);
  }

  Future<Dano> create({
    required String clienteId,
    required DateTime fechaReporte,
    required String descripcion,
    int costo = 0,
    String? reportadoPor,
    String? notas,
  }) async {
    final data = await _client
        .from('danos')
        .insert({
          'tenant_id': _tenantId,
          'cliente_id': clienteId,
          'fecha_reporte': _toDateOnly(fechaReporte),
          'descripcion': descripcion,
          'costo': costo,
          'reportado_por': reportadoPor,
          'notas': notas,
          'estado': EstadoDano.reportado.value,
        })
        .select()
        .single();
    return Dano.fromJson(data);
  }

  Future<Dano> update(
    String id, {
    String? descripcion,
    int? costo,
    String? reportadoPor,
    String? notas,
    EstadoDano? estado,
    DateTime? fechaSolucion,
  }) async {
    final patch = <String, dynamic>{
      if (descripcion != null) 'descripcion': descripcion,
      if (costo != null) 'costo': costo,
      'reportado_por': reportadoPor,
      'notas': notas,
      if (estado != null) 'estado': estado.value,
      if (fechaSolucion != null) 'fecha_solucion': _toDateOnly(fechaSolucion),
    };
    final data = await _client
        .from('danos')
        .update(patch)
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .select()
        .single();
    return Dano.fromJson(data);
  }

  static String _toDateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final danoRepositoryProvider = Provider<DanoRepository>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final client = ref.watch(supabaseClientProvider);
  return DanoRepository(client: client, perfil: perfil);
});
