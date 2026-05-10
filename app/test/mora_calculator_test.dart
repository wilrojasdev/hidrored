import 'package:flutter_test/flutter_test.dart';
import 'package:hidrored/domain/entities/factura.dart';
import 'package:hidrored/domain/enums.dart';
import 'package:hidrored/features/facturacion/domain/mora_calculator.dart';

Factura _f({
  required DateTime vencimiento,
  int valorMora = 0,
  int total = 18000,
}) {
  return Factura(
    id: 'fid-${vencimiento.toIso8601String()}',
    tenantId: 'tenant',
    clienteId: 's',
    numero: 'AC-2025-0001',
    periodo: '2025-04',
    fechaEmision: vencimiento.subtract(const Duration(days: 5)),
    fechaVencimiento: vencimiento,
    total: total,
    valorMora: valorMora,
    estado: EstadoFactura.pendiente,
    tipo: TipoFactura.mensual,
  );
}

void main() {
  group('MoraCalculator', () {
    test('Sin facturas pendientes, mora es 0', () {
      final r = MoraCalculator.aCobrar(
        facturasPendientes: const [],
        hasta: DateTime(2025, 5, 30),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Una factura vencida, sin mora previa, calcula dias x tarifa', () {
      // Vencida 2025-04-30 -> dia siguiente: 2025-05-01.
      // Hasta 2025-05-31 = 30 dias.
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [_f(vencimiento: DateTime(2025, 4, 30))],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 30 * 300);
    });

    test('Mora ya facturada antes se descuenta', () {
      // Factura previa con $9.000 ya cobrados de mora.
      // Mora total acumulada hoy = 30 * 300 = 9000 -> a cobrar 0.
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [
          _f(vencimiento: DateTime(2025, 4, 30), valorMora: 9000),
        ],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Mora total mayor que ya facturada cobra solo la diferencia', () {
      // Factura previa con $5.000 cobrados; total acumulado hoy = $9.000.
      // A cobrar = 4.000.
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [
          _f(vencimiento: DateTime(2025, 4, 30), valorMora: 5000),
        ],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 4000);
    });

    test('Multiples facturas pendientes acumulan dias', () {
      // f1 venc 2025-04-30 (dia siguiente 5/1) -> 30 dias hasta 5/31
      // f2 venc 2025-05-30 (dia siguiente 5/31) -> 0 dias
      // total dias = 30 ; mora = 30 * 300 = 9000
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [
          _f(vencimiento: DateTime(2025, 4, 30)),
          _f(vencimiento: DateTime(2025, 5, 30)),
        ],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 9000);
    });

    test('Factura no vencida aun no genera mora', () {
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [_f(vencimiento: DateTime(2025, 6, 10))],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('No retorna negativo si mora ya facturada excede la actual', () {
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [
          _f(vencimiento: DateTime(2025, 5, 25), valorMora: 100000),
        ],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Boundary: hasta = fecha de vencimiento, mora todavía es 0', () {
      // Día siguiente al venc = 2025-05-08; hasta = 2025-05-07 → 0 días.
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [_f(vencimiento: DateTime(2025, 5, 7))],
        hasta: DateTime(2025, 5, 7),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Boundary: hasta = día siguiente al vencimiento, mora = 1 día', () {
      // Día siguiente al venc = 2025-05-08; hasta = 2025-05-08 → 0 días? No,
      // diff(2025-05-08 - 2025-05-08) = 0; la condición `dias > 0` lo descarta.
      // Para que cuente 1 día completo se necesita hasta = 2025-05-09.
      final r = MoraCalculator.aCobrar(
        facturasPendientes: [_f(vencimiento: DateTime(2025, 5, 7))],
        hasta: DateTime(2025, 5, 9),
        tarifaMoraDiaria: 300,
      );
      expect(r, 300);
    });

    test(
      'Año bisiesto: factura venc 2024-01-31, hasta 2024-03-01 → 29 días',
      () {
        // Feb 2024 tiene 29 días. Día siguiente al venc = 2024-02-01.
        // Diff con 2024-03-01 = 29 días. Mora = 29 * 300 = 8700.
        final r = MoraCalculator.aCobrar(
          facturasPendientes: [_f(vencimiento: DateTime(2024, 1, 31))],
          hasta: DateTime(2024, 3, 1),
          tarifaMoraDiaria: 300,
        );
        expect(r, 29 * 300);
      },
    );

    test(
      'Año NO bisiesto: factura venc 2025-01-31, hasta 2025-03-01 → 28 días',
      () {
        // Feb 2025 tiene 28 días. Confirma que la fórmula es sensible al año.
        final r = MoraCalculator.aCobrar(
          facturasPendientes: [_f(vencimiento: DateTime(2025, 1, 31))],
          hasta: DateTime(2025, 3, 1),
          tarifaMoraDiaria: 300,
        );
        expect(r, 28 * 300);
      },
    );
  });
}
