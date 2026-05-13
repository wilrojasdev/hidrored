import 'package:flutter_test/flutter_test.dart';
import 'package:hidrored/domain/entities/factura.dart';
import 'package:hidrored/domain/enums.dart';
import 'package:hidrored/features/facturacion/domain/mora_calculator.dart';

DeudaParaMora _d({required DateTime vencimiento, int valorMora = 0}) =>
    DeudaParaMora(fechaVencimiento: vencimiento, moraYaFacturada: valorMora);

Factura _f({
  required DateTime vencimiento,
  int valorMora = 0,
  int total = 18000,
  String id = 'fid',
}) {
  return Factura(
    id: id,
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
  group('MoraCalculator.aCobrar', () {
    test('Sin deudas, mora es 0', () {
      final r = MoraCalculator.aCobrar(
        deudas: const [],
        hasta: DateTime(2025, 5, 30),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Una deuda vencida, sin mora previa, calcula dias x tarifa', () {
      // Vencida 2025-04-30 -> dia siguiente: 2025-05-01.
      // Hasta 2025-05-31 = 30 dias.
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2025, 4, 30))],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 30 * 300);
    });

    test('Mora ya facturada antes se descuenta', () {
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2025, 4, 30), valorMora: 9000)],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Mora total mayor que ya facturada cobra solo la diferencia', () {
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2025, 4, 30), valorMora: 5000)],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 4000);
    });

    test('Multiples deudas pendientes acumulan dias', () {
      final r = MoraCalculator.aCobrar(
        deudas: [
          _d(vencimiento: DateTime(2025, 4, 30)),
          _d(vencimiento: DateTime(2025, 5, 30)),
        ],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 9000);
    });

    test('Deuda no vencida aun no genera mora', () {
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2025, 6, 10))],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('No retorna negativo si mora ya facturada excede la actual', () {
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2025, 5, 25), valorMora: 100000)],
        hasta: DateTime(2025, 5, 31),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Boundary: hasta = fecha de vencimiento, mora todavía es 0', () {
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2025, 5, 7))],
        hasta: DateTime(2025, 5, 7),
        tarifaMoraDiaria: 300,
      );
      expect(r, 0);
    });

    test('Boundary: hasta = día siguiente al vencimiento, mora = 1 día', () {
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2025, 5, 7))],
        hasta: DateTime(2025, 5, 9),
        tarifaMoraDiaria: 300,
      );
      expect(r, 300);
    });

    test('Año bisiesto: deuda venc 2024-01-31, hasta 2024-03-01 → 29 días', () {
      final r = MoraCalculator.aCobrar(
        deudas: [_d(vencimiento: DateTime(2024, 1, 31))],
        hasta: DateTime(2024, 3, 1),
        tarifaMoraDiaria: 300,
      );
      expect(r, 29 * 300);
    });

    test(
      'Año NO bisiesto: deuda venc 2025-01-31, hasta 2025-03-01 → 28 días',
      () {
        final r = MoraCalculator.aCobrar(
          deudas: [_d(vencimiento: DateTime(2025, 1, 31))],
          hasta: DateTime(2025, 3, 1),
          tarifaMoraDiaria: 300,
        );
        expect(r, 28 * 300);
      },
    );
  });

  group('MoraCalculator.descomponer', () {
    test('Factura sin lineas refacturadas: 1 sub-deuda con sus datos', () {
      final f = _f(vencimiento: DateTime(2025, 5, 31), valorMora: 1500);
      final deudas = MoraCalculator.descomponer(
        facturasPendientes: [f],
        saldosRefacturadosPorFactura: const {},
      );
      expect(deudas, hasLength(1));
      expect(deudas.first.fechaVencimiento, DateTime(2025, 5, 31));
      expect(deudas.first.moraYaFacturada, 1500);
    });

    test(
      'Factura con 1 linea refacturada: 2 sub-deudas, mora atribuida a la nativa',
      () {
        // Factura "abril" total $70.000 = $20.000 nativos + $50.000 refacturado
        // de marzo (vto 2025-04-15).
        final f = _f(
          vencimiento: DateTime(2025, 5, 31),
          valorMora: 3000,
          total: 70000,
          id: 'abril',
        );
        final deudas = MoraCalculator.descomponer(
          facturasPendientes: [f],
          saldosRefacturadosPorFactura: {
            'abril': [
              SubDeudaRefacturada(
                monto: 50000,
                fechaVencimientoOrigen: DateTime(2025, 4, 15),
              ),
            ],
          },
        );
        expect(deudas, hasLength(2));
        // Sub-deuda refacturada (vto marzo): no acumula mora-ya-facturada
        expect(deudas[0].fechaVencimiento, DateTime(2025, 4, 15));
        expect(deudas[0].moraYaFacturada, 0);
        // Sub-deuda nativa (vto abril): acumula la mora capturada
        expect(deudas[1].fechaVencimiento, DateTime(2025, 5, 31));
        expect(deudas[1].moraYaFacturada, 3000);
      },
    );

    test(
      '100% refacturada (saldo nativo = 0): mora-ya-facturada migra a la primera sub-deuda',
      () {
        // Caso edge: factura en la que TODO el total es saldo refacturado.
        final f = _f(
          vencimiento: DateTime(2025, 5, 31),
          valorMora: 2000,
          total: 50000,
          id: 'abril',
        );
        final deudas = MoraCalculator.descomponer(
          facturasPendientes: [f],
          saldosRefacturadosPorFactura: {
            'abril': [
              SubDeudaRefacturada(
                monto: 50000,
                fechaVencimientoOrigen: DateTime(2025, 4, 15),
              ),
            ],
          },
        );
        expect(deudas, hasLength(1));
        expect(deudas[0].fechaVencimiento, DateTime(2025, 4, 15));
        // La mora capturada se preserva en la unica sub-deuda existente.
        expect(deudas[0].moraYaFacturada, 2000);
      },
    );
  });
}
