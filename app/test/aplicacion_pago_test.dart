import 'package:flutter_test/flutter_test.dart';
import 'package:hidrored/domain/entities/factura.dart';
import 'package:hidrored/domain/enums.dart';
import 'package:hidrored/features/pagos/domain/aplicacion_pago.dart';

Factura _f({
  required String id,
  required DateTime emision,
  int total = 18000,
  String numero = 'AC-2025-0001',
}) {
  return Factura(
    id: id,
    tenantId: 't',
    clienteId: 's',
    numero: numero,
    periodo: '2025-04',
    fechaEmision: emision,
    fechaVencimiento: emision.add(const Duration(days: 5)),
    total: total,
    estado: EstadoFactura.pendiente,
    tipo: TipoFactura.mensual,
  );
}

void main() {
  group('AplicacionPagoCalculator', () {
    test('Pago exacto cierra todas las facturas en orden', () {
      final f1 = _f(id: '1', emision: DateTime(2025, 1, 1));
      final f2 = _f(id: '2', emision: DateTime(2025, 2, 1));
      final f3 = _f(id: '3', emision: DateTime(2025, 3, 1));

      final r = AplicacionPagoCalculator.calcular(
        facturasPendientes: [f3, f1, f2],
        valorPago: 54000,
      );

      expect(r.aplicaciones.length, 3);
      expect(r.aplicaciones[0].factura.id, '1'); // FIFO orden
      expect(r.aplicaciones[1].factura.id, '2');
      expect(r.aplicaciones[2].factura.id, '3');
      expect(r.totalAplicado, 54000);
      expect(r.sobrante, 0);
      expect(r.faltante, 0);
      expect(r.esExacto, isTrue);
    });

    test('Pago insuficiente cubre primeras y faltante refleja diferencia', () {
      final f1 = _f(id: '1', emision: DateTime(2025, 1, 1));
      final f2 = _f(id: '2', emision: DateTime(2025, 2, 1));

      final r = AplicacionPagoCalculator.calcular(
        facturasPendientes: [f1, f2],
        valorPago: 20000,
      );

      // f1 cierra completa (18000), f2 recibe 2000.
      expect(r.aplicaciones.length, 2);
      expect(r.aplicaciones[0].monto, 18000);
      expect(r.aplicaciones[1].monto, 2000);
      expect(r.faltante, 16000); // 36000 - 20000
      expect(r.sobrante, 0);
      expect(r.cubreTodo, isFalse);
    });

    test('Pago superior al saldo deja sobrante', () {
      final f1 = _f(id: '1', emision: DateTime(2025, 1, 1));

      final r = AplicacionPagoCalculator.calcular(
        facturasPendientes: [f1],
        valorPago: 25000,
      );

      expect(r.aplicaciones.length, 1);
      expect(r.aplicaciones.first.monto, 18000);
      expect(r.sobrante, 7000);
      expect(r.faltante, 0);
    });

    test('Sin facturas pendientes solo registra el pago como sobrante', () {
      final r = AplicacionPagoCalculator.calcular(
        facturasPendientes: const [],
        valorPago: 18000,
      );

      expect(r.aplicaciones, isEmpty);
      expect(r.sobrante, 18000);
      expect(r.faltante, 0);
    });

    test('Empate en fecha de emision usa numero como desempate', () {
      final f1 = _f(
        id: '1',
        emision: DateTime(2025, 1, 1),
        numero: 'AC-2025-0002',
      );
      final f2 = _f(
        id: '2',
        emision: DateTime(2025, 1, 1),
        numero: 'AC-2025-0001',
      );

      final r = AplicacionPagoCalculator.calcular(
        facturasPendientes: [f1, f2],
        valorPago: 18000,
      );

      // Numero menor primero
      expect(r.aplicaciones.first.factura.id, '2');
    });
  });
}
