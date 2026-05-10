import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/clock.dart';
import '../../../data/supabase_providers.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';

class ClienteRepository {
  ClienteRepository({required SupabaseClient client, required Perfil perfil})
    : _client = client,
      _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final String _tenantId;

  Future<List<Cliente>> list({String? search}) async {
    var query = _client.from('clientes').select().eq('tenant_id', _tenantId);

    if (search != null && search.trim().isNotEmpty) {
      final term = '%${search.trim()}%';
      query = query.or(
        'nombre.ilike.$term,'
        'cedula.ilike.$term,'
        'direccion.ilike.$term',
      );
    }

    final data = await query.order('codigo', ascending: true);
    return (data as List)
        .map((row) => Cliente.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Cliente> get(String id) async {
    final data = await _client
        .from('clientes')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .single();
    return Cliente.fromJson(data);
  }

  /// Devuelve el siguiente codigo (consecutivo dentro del tenant).
  Future<int> nextCodigo() async {
    final data = await _client
        .from('clientes')
        .select('codigo')
        .eq('tenant_id', _tenantId)
        .order('codigo', ascending: false)
        .limit(1);
    final list = data as List;
    if (list.isEmpty) return 1;
    final ultimo = (list.first as Map<String, dynamic>)['codigo'] as int;
    return ultimo + 1;
  }

  Future<Cliente> create({
    required int codigo,
    required String cedula,
    required String nombre,
    String? direccion,
    String? telefono,
    String? sector,
    String? zona,
    String? barrio,
    required int tarifaMensual,
    EstadoCliente estado = EstadoCliente.activo,
    int deudaInicial = 0,
    String? notas,
  }) async {
    final data = await _client
        .from('clientes')
        .insert({
          'tenant_id': _tenantId,
          'codigo': codigo,
          'cedula': cedula,
          'nombre': nombre,
          'direccion': direccion,
          'telefono': telefono,
          'sector': sector,
          'zona': zona,
          'barrio': barrio,
          'tarifa_mensual': tarifaMensual,
          'estado': estado.value,
          'deuda_inicial': deudaInicial,
          'notas': notas,
        })
        .select()
        .single();
    return Cliente.fromJson(data);
  }

  Future<Cliente> update(
    String id, {
    String? cedula,
    String? nombre,
    String? direccion,
    String? telefono,
    String? sector,
    String? zona,
    String? barrio,
    int? tarifaMensual,
    EstadoCliente? estado,
    int? deudaInicial,
    String? notas,
  }) async {
    final patch = <String, dynamic>{
      if (cedula != null) 'cedula': cedula,
      if (nombre != null) 'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'sector': sector,
      'zona': zona,
      'barrio': barrio,
      if (tarifaMensual != null) 'tarifa_mensual': tarifaMensual,
      if (estado != null) 'estado': estado.value,
      if (deudaInicial != null) 'deuda_inicial': deudaInicial,
      'notas': notas,
    };
    final data = await _client
        .from('clientes')
        .update(patch)
        .eq('tenant_id', _tenantId)
        .eq('id', id)
        .select()
        .single();
    return Cliente.fromJson(data);
  }

  /// Marca como retirado (no hard delete — se preserva historico).
  Future<void> retirar(String id) async {
    await _client
        .from('clientes')
        .update({
          'estado': EstadoCliente.retirado.value,
          'fecha_retiro': BogotaClock.hoyIso(),
        })
        .eq('tenant_id', _tenantId)
        .eq('id', id);
  }
}

final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError(
      'No hay perfil cargado: el repository requiere un usuario autenticado.',
    );
  }
  final client = ref.watch(supabaseClientProvider);
  return ClienteRepository(client: client, perfil: perfil);
});
