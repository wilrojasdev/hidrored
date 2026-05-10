import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/festivos_colombia.dart';
import '../../../data/supabase_providers.dart';
import '../../../data/tenant_provider.dart';
import '../../../domain/entities/cargo_pendiente.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/enums.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cargos/data/cargo_pendiente_repository.dart';
import 'mora_calculator.dart';
import 'preview_facturacion.dart';

/// Logica de negocio del ciclo de facturacion.
///
/// Reglas implementadas:
/// - El recibo del mes se emite el ultimo dia del mes (o cuando el admin
///   ejecuta la facturacion masiva).
/// - Vencimiento = fecha_emision + N dias habiles (segun tenant.diasHabiles).
/// - Mora: por cada factura pendiente, se cuentan los dias calendario
///   desde el dia siguiente a su vencimiento hasta hoy. Suma de dias x
///   tarifa_mora_diaria.
/// - La mora ya cobrada en facturas pendientes anteriores se descuenta
///   para evitar doble cobro.
/// - Cliente activo: factura mensual con valor_mensualidad y mora.
/// - Cliente suspendido: factura "recordatorio_suspension" con mora +
///   costo_reconexion (sin nueva mensualidad).
/// - Cliente retirado: no se le emite factura.
/// - Cargos extra (conceptos) en cola del cliente se incluyen como
///   líneas adicionales y quedan marcados como aplicados a esta factura.
///   Si la factura se anula, vuelven a estar pendientes.
class BillingService {
  BillingService({
    required SupabaseClient client,
    required this.tenant,
    required Perfil perfil,
    required CargoPendienteRepository cargosRepo,
  }) : _client = client,
       _cargosRepo = cargosRepo,
       _tenantId = perfil.tenantId;

  final SupabaseClient _client;
  final CargoPendienteRepository _cargosRepo;
  final Tenant tenant;
  final String _tenantId;

  // ---------- Preview masivo ----------

  Future<List<PreviewFacturaCliente>> previewFacturacion({
    required String periodo,
    required DateTime fechaEmision,
  }) async {
    final clientes = await _cargarClientesNoRetirados();
    final pendientes = await _cargarFacturasPendientes();
    final cargos = await _cargosRepo.listPendientesDelTenant();

    final pendientesPorCliente = <String, List<Factura>>{};
    for (final f in pendientes) {
      pendientesPorCliente.putIfAbsent(f.clienteId, () => []).add(f);
    }
    final cargosPorCliente = <String, List<CargoPendiente>>{};
    for (final c in cargos) {
      cargosPorCliente.putIfAbsent(c.clienteId, () => []).add(c);
    }

    return clientes.map((s) {
      return _construirPreview(
        cliente: s,
        facturasPendientes: pendientesPorCliente[s.id] ?? const [],
        cargosExtras: cargosPorCliente[s.id] ?? const [],
        fechaEmision: fechaEmision,
      );
    }).toList();
  }

  // ---------- Preview individual ----------

  /// Calcula el preview de UN solo cliente (para "Generar factura
  /// individual" o "Re-emitir tras anulación").
  Future<PreviewFacturaCliente> previewFacturaIndividual({
    required String clienteId,
    required String periodo,
    required DateTime fechaEmision,
  }) async {
    final cliente = await _cargarCliente(clienteId);
    if (cliente.estado == EstadoCliente.retirado) {
      throw StateError('No se puede emitir factura: el cliente está retirado.');
    }
    final pendientes = await _cargarFacturasPendientesCliente(clienteId);
    final cargos = await _cargosRepo.listPorCliente(clienteId);

    return _construirPreview(
      cliente: cliente,
      facturasPendientes: pendientes,
      cargosExtras: cargos,
      fechaEmision: fechaEmision,
    );
  }

  // ---------- Ejecutar masivo ----------

  /// Ejecuta la facturacion masiva. Devuelve la cantidad de facturas
  /// creadas. Usa el RPC `generar_facturacion_masiva` que omite
  /// silenciosamente clientes con factura no-anulada del mismo periodo.
  Future<int> ejecutarFacturacion({
    required String periodo,
    required DateTime fechaEmision,
  }) async {
    final preview = await previewFacturacion(
      periodo: periodo,
      fechaEmision: fechaEmision,
    );
    final fechaVencimiento = FestivosColombia.sumarDiasHabiles(
      fechaEmision,
      tenant.diasHabilesPago,
    );

    final facturasPayload = <Map<String, dynamic>>[];
    for (final p in preview) {
      if (!p.tieneCargos) continue;
      facturasPayload.add(_payloadFactura(p, periodo));
    }
    if (facturasPayload.isEmpty) return 0;

    final result = await _client.rpc(
      'generar_facturacion_masiva',
      params: {
        'p_periodo': periodo,
        'p_fecha_emision': _toDateOnly(fechaEmision),
        'p_fecha_vencimiento': _toDateOnly(fechaVencimiento),
        'p_facturas': facturasPayload,
      },
    );
    return (result as num).toInt();
  }

  // ---------- Ejecutar individual ----------

  /// Emite UNA factura para un cliente específico. Falla si ya existe
  /// factura no-anulada del mismo periodo.
  Future<void> ejecutarFacturaIndividual({
    required PreviewFacturaCliente preview,
    required String periodo,
    required DateTime fechaEmision,
  }) async {
    if (!preview.tieneCargos) {
      throw StateError(
        'No hay cargos para facturar a ${preview.cliente.nombre}.',
      );
    }
    final fechaVencimiento = FestivosColombia.sumarDiasHabiles(
      fechaEmision,
      tenant.diasHabilesPago,
    );
    await _client.rpc(
      'generar_factura_individual',
      params: {
        'p_periodo': periodo,
        'p_fecha_emision': _toDateOnly(fechaEmision),
        'p_fecha_vencimiento': _toDateOnly(fechaVencimiento),
        'p_factura': _payloadFactura(preview, periodo),
      },
    );
  }

  // ---------- privados ----------

  Map<String, dynamic> _payloadFactura(
    PreviewFacturaCliente p,
    String periodo,
  ) {
    final lineas = <Map<String, dynamic>>[];
    if (p.valorMensualidad > 0) {
      lineas.add({
        'descripcion': 'Mensualidad ${_periodoLabel(periodo)}',
        'cantidad': 1,
        'valor_unitario': p.valorMensualidad,
        'subtotal': p.valorMensualidad,
      });
    }
    if (p.valorMora > 0) {
      lineas.add({
        'descripcion': 'Intereses de mora',
        'cantidad': 1,
        'valor_unitario': p.valorMora,
        'subtotal': p.valorMora,
      });
    }
    if (p.costoReconexion > 0) {
      lineas.add({
        'descripcion': 'Costo de reconexión',
        'cantidad': 1,
        'valor_unitario': p.costoReconexion,
        'subtotal': p.costoReconexion,
      });
    }
    for (final c in p.cargosExtras) {
      lineas.add({
        'cargo_pendiente_id': c.id,
        'concepto_id': c.conceptoId,
        'descripcion': c.descripcion,
        'cantidad': c.cantidad,
        'valor_unitario': c.valorUnitario,
        'subtotal': c.subtotal,
      });
    }
    return {
      'cliente_id': p.cliente.id,
      'tipo': p.tipo.value,
      'valor_mensualidad': p.valorMensualidad,
      'valor_mora': p.valorMora,
      'total': p.totalFacturaNueva,
      'lineas': lineas,
    };
  }

  PreviewFacturaCliente _construirPreview({
    required Cliente cliente,
    required List<Factura> facturasPendientes,
    required List<CargoPendiente> cargosExtras,
    required DateTime fechaEmision,
  }) {
    final esSuspendido =
        cliente.estado == EstadoCliente.suspendidoMora ||
        cliente.estado == EstadoCliente.suspendidoVoluntario;

    final tipo = esSuspendido
        ? TipoFactura.recordatorioSuspension
        : TipoFactura.mensual;

    final totalAtrasos = facturasPendientes.fold<int>(
      0,
      (sum, f) => sum + f.total,
    );

    final valorMora = MoraCalculator.aCobrar(
      facturasPendientes: facturasPendientes,
      hasta: fechaEmision,
      tarifaMoraDiaria: tenant.tarifaMoraDiaria,
    );

    final valorMensualidad = esSuspendido ? 0 : cliente.tarifaMensual;
    final costoReconexion = esSuspendido ? tenant.costoReconexion : 0;

    return PreviewFacturaCliente(
      cliente: cliente,
      tipo: tipo,
      totalAtrasos: totalAtrasos,
      cantidadAtrasos: facturasPendientes.length,
      valorMensualidad: valorMensualidad,
      valorMora: valorMora,
      costoReconexion: costoReconexion,
      cargosExtras: cargosExtras,
    );
  }

  Future<List<Cliente>> _cargarClientesNoRetirados() async {
    final data = await _client
        .from('clientes')
        .select()
        .eq('tenant_id', _tenantId)
        .neq('estado', EstadoCliente.retirado.value)
        .order('codigo');
    return (data as List)
        .map((row) => Cliente.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Cliente> _cargarCliente(String clienteId) async {
    final data = await _client
        .from('clientes')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('id', clienteId)
        .single();
    return Cliente.fromJson(data);
  }

  Future<List<Factura>> _cargarFacturasPendientes() async {
    final data = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('estado', EstadoFactura.pendiente.value)
        .order('fecha_emision');
    return (data as List)
        .map((row) => Factura.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Factura>> _cargarFacturasPendientesCliente(
    String clienteId,
  ) async {
    final data = await _client
        .from('facturas')
        .select()
        .eq('tenant_id', _tenantId)
        .eq('cliente_id', clienteId)
        .eq('estado', EstadoFactura.pendiente.value)
        .order('fecha_emision');
    return (data as List)
        .map((row) => Factura.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  static String _toDateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _periodoLabel(String periodo) {
    final parts = periodo.split('-');
    if (parts.length != 2) return periodo;
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    if (m < 1 || m > 12) return periodo;
    return '${meses[m]} ${parts[0]}';
  }
}

final billingServiceProvider = FutureProvider<BillingService>((ref) async {
  final perfil = ref.watch(perfilProvider).valueOrNull;
  if (perfil == null) {
    throw StateError('No hay perfil cargado');
  }
  final tenant = await ref.watch(tenantProvider.future);
  final client = ref.watch(supabaseClientProvider);
  final cargosRepo = ref.watch(cargoPendienteRepositoryProvider);
  return BillingService(
    client: client,
    tenant: tenant,
    perfil: perfil,
    cargosRepo: cargosRepo,
  );
});
