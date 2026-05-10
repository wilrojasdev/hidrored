import 'package:flutter_test/flutter_test.dart';
import 'package:hidrored/domain/entities/cliente.dart';
import 'package:hidrored/domain/entities/factura.dart';
import 'package:hidrored/features/servicio/domain/lista_corte_service.dart';

const _tenantId = 't';

Cliente _cliente() => Cliente(
  id: 'c1',
  tenantId: _tenantId,
  codigo: 1,
  cedula: '123',
  nombre: 'Juan Pérez',
  tarifaMensual: 18000,
  fechaIngreso: DateTime(2024, 1, 1),
);

Factura _factura({
  required String periodo,
  required DateTime emision,
  required DateTime vencimiento,
  int total = 18000,
}) => Factura(
  id: 'f-$periodo',
  tenantId: _tenantId,
  clienteId: 'c1',
  numero: 'DSQ-$periodo',
  periodo: periodo,
  fechaEmision: emision,
  fechaVencimiento: vencimiento,
  total: total,
);

void main() {
  group('ListaCorteService.evaluarCliente', () {
    test('Sin facturas pendientes, no califica', () {
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: const [],
        ahora: DateTime(2025, 6, 15),
      );
      expect(result, isNull);
    });

    test('Una sola factura pendiente, no califica (necesita >= 2)', () {
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2025-04',
            emision: DateTime(2025, 4, 30),
            vencimiento: DateTime(2025, 5, 7),
          ),
        ],
        ahora: DateTime(2025, 6, 15),
      );
      expect(result, isNull);
    });

    test('Dos meses CONSECUTIVOS vencidos: candidato', () {
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2025-04',
            emision: DateTime(2025, 4, 30),
            vencimiento: DateTime(2025, 5, 7),
          ),
          _factura(
            periodo: '2025-05',
            emision: DateTime(2025, 5, 31),
            vencimiento: DateTime(2025, 6, 6),
          ),
        ],
        ahora: DateTime(2025, 6, 15),
      );
      expect(result, isNotNull);
      expect(result!.mesesConsecutivosEnMora, 2);
      expect(result.totalAdeudado, 36000);
    });

    test('Dos meses NO consecutivos vencidos: no califica', () {
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2025-03',
            emision: DateTime(2025, 3, 31),
            vencimiento: DateTime(2025, 4, 7),
          ),
          _factura(
            periodo: '2025-05',
            emision: DateTime(2025, 5, 31),
            vencimiento: DateTime(2025, 6, 6),
          ),
        ],
        ahora: DateTime(2025, 6, 15),
      );
      expect(result, isNull);
    });

    test('Segunda factura aún NO vencida: no califica todavía', () {
      // 2025-05 emitida pero todavía dentro del plazo de 5 días hábiles.
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2025-04',
            emision: DateTime(2025, 4, 30),
            vencimiento: DateTime(2025, 5, 7),
          ),
          _factura(
            periodo: '2025-05',
            emision: DateTime(2025, 5, 31),
            vencimiento: DateTime(2025, 6, 6),
          ),
        ],
        ahora: DateTime(2025, 6, 5), // antes del vencimiento de 2025-05
      );
      expect(result, isNull);
    });

    test('Día EXACTO del vencimiento todavía cuenta como NO vencida', () {
      // Boundary: ahora == fechaVencimiento. Debe ser estricto: aún en plazo.
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2025-04',
            emision: DateTime(2025, 4, 30),
            vencimiento: DateTime(2025, 5, 7),
          ),
          _factura(
            periodo: '2025-05',
            emision: DateTime(2025, 5, 31),
            vencimiento: DateTime(2025, 6, 6),
          ),
        ],
        ahora: DateTime(2025, 6, 6), // exactamente el vencimiento
      );
      expect(result, isNull);
    });

    test('Tres meses consecutivos: corrida = 3', () {
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2025-03',
            emision: DateTime(2025, 3, 31),
            vencimiento: DateTime(2025, 4, 7),
          ),
          _factura(
            periodo: '2025-04',
            emision: DateTime(2025, 4, 30),
            vencimiento: DateTime(2025, 5, 7),
          ),
          _factura(
            periodo: '2025-05',
            emision: DateTime(2025, 5, 31),
            vencimiento: DateTime(2025, 6, 6),
          ),
        ],
        ahora: DateTime(2025, 6, 15),
      );
      expect(result, isNotNull);
      expect(result!.mesesConsecutivosEnMora, 3);
    });

    test('Cruce de año: 2024-12 y 2025-01 son consecutivos', () {
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2024-12',
            emision: DateTime(2024, 12, 31),
            vencimiento: DateTime(2025, 1, 7),
          ),
          _factura(
            periodo: '2025-01',
            emision: DateTime(2025, 1, 31),
            vencimiento: DateTime(2025, 2, 7),
          ),
        ],
        ahora: DateTime(2025, 2, 15),
      );
      expect(result, isNotNull);
      expect(result!.mesesConsecutivosEnMora, 2);
    });

    test('Hueco + corrida: cuenta solo la corrida más larga', () {
      // Pendientes 2024-11 (sola, vencida) + 2025-04, 2025-05 (consecutivas).
      // Corrida más larga = 2 (los meses 04, 05).
      final result = ListaCorteService.evaluarCliente(
        cliente: _cliente(),
        pendientes: [
          _factura(
            periodo: '2024-11',
            emision: DateTime(2024, 11, 30),
            vencimiento: DateTime(2024, 12, 9),
          ),
          _factura(
            periodo: '2025-04',
            emision: DateTime(2025, 4, 30),
            vencimiento: DateTime(2025, 5, 7),
          ),
          _factura(
            periodo: '2025-05',
            emision: DateTime(2025, 5, 31),
            vencimiento: DateTime(2025, 6, 6),
          ),
        ],
        ahora: DateTime(2025, 6, 15),
      );
      expect(result, isNotNull);
      expect(result!.mesesConsecutivosEnMora, 2);
    });
  });
}
