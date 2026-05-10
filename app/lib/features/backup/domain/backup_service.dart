import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase_providers.dart';
import '../../../data/tenant_provider.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/tenant.dart';
import '../../auth/presentation/auth_controller.dart';

/// Genera un backup completo del tenant en formato JSON.
class BackupService {
  BackupService({
    required SupabaseClient client,
    required this.tenant,
    required Perfil perfil,
  }) : _client = client,
       _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final Tenant tenant;
  final String _tenantId;

  /// Carga todas las tablas del tenant y devuelve un JSON serializado en
  /// bytes UTF-8, listo para guardar en archivo.
  Future<({Uint8List bytes, String filename})> exportar() async {
    final data = await _cargarTodo();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = Uint8List.fromList(utf8.encode(json));
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filename = 'hidrored-backup-${tenant.prefijoRecibos}-$timestamp.json';
    return (bytes: bytes, filename: filename);
  }

  Future<Map<String, dynamic>> _cargarTodo() async {
    final results = await Future.wait([
      _table('clientes'),
      _table('conceptos'),
      _table('facturas'),
      _table('factura_lineas'),
      _table('pagos'),
      _table('pago_factura'),
      _table('eventos_servicio'),
      _table('danos'),
    ]);

    final tenantData = await _client
        .from('tenants')
        .select()
        .eq('id', _tenantId)
        .single();

    return {
      'meta': {
        'generado_en': DateTime.now().toIso8601String(),
        'tenant_id': _tenantId,
        'version': '1.0',
      },
      'tenant': tenantData,
      'clientes': results[0],
      'conceptos': results[1],
      'facturas': results[2],
      'factura_lineas': results[3],
      'pagos': results[4],
      'pago_factura': results[5],
      'eventos_servicio': results[6],
      'danos': results[7],
    };
  }

  Future<List<Map<String, dynamic>>> _table(String nombre) async {
    final data = await _client.from(nombre).select().eq('tenant_id', _tenantId);
    return [for (final row in data as List) (row as Map<String, dynamic>)];
  }
}

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final tenant = await ref.watch(tenantProvider.future);
  final client = ref.watch(supabaseClientProvider);
  return BackupService(client: client, tenant: tenant, perfil: perfil);
});
