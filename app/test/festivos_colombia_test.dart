import 'package:flutter_test/flutter_test.dart';
import 'package:hidrored/core/utils/festivos_colombia.dart';

void main() {
  group('Festivos Colombia 2025', () {
    test('1 enero es festivo', () {
      expect(FestivosColombia.esFestivo(DateTime(2025, 1, 1)), isTrue);
    });

    test('1 mayo (dia del trabajo) es festivo', () {
      expect(FestivosColombia.esFestivo(DateTime(2025, 5, 1)), isTrue);
    });

    test('Reyes Magos 2025 es lunes 6 de enero', () {
      // 2025-01-06 es lunes, no se mueve
      expect(FestivosColombia.esFestivo(DateTime(2025, 1, 6)), isTrue);
    });

    test('San Jose 2025 se mueve a lunes 24 de marzo', () {
      // 2025-03-19 es miercoles -> mueve a lunes 24
      expect(FestivosColombia.esFestivo(DateTime(2025, 3, 24)), isTrue);
      expect(FestivosColombia.esFestivo(DateTime(2025, 3, 19)), isFalse);
    });

    test('Jueves Santo y Viernes Santo 2025', () {
      // Pascua 2025 = 20 abril. Jueves: 17, Viernes: 18
      expect(FestivosColombia.esFestivo(DateTime(2025, 4, 17)), isTrue);
      expect(FestivosColombia.esFestivo(DateTime(2025, 4, 18)), isTrue);
    });

    test('Un dia laboral comun no es festivo', () {
      expect(FestivosColombia.esFestivo(DateTime(2025, 5, 14)), isFalse);
    });
  });

  group('Dias habiles', () {
    test('Sabado y domingo no son habiles', () {
      // 2025-05-10 es sabado, 11 domingo
      expect(FestivosColombia.esDiaHabil(DateTime(2025, 5, 10)), isFalse);
      expect(FestivosColombia.esDiaHabil(DateTime(2025, 5, 11)), isFalse);
    });

    test('Lunes-jueves comun es habil', () {
      expect(FestivosColombia.esDiaHabil(DateTime(2025, 5, 13)), isTrue); // mar
      expect(FestivosColombia.esDiaHabil(DateTime(2025, 5, 14)), isTrue); // mie
    });

    test('Festivo no es habil', () {
      expect(FestivosColombia.esDiaHabil(DateTime(2025, 5, 1)), isFalse);
    });

    test('sumarDiasHabiles desde viernes salta sabado y domingo', () {
      // Viernes 9 mayo 2025 + 1 dia habil = lunes 12 mayo
      final r = FestivosColombia.sumarDiasHabiles(DateTime(2025, 5, 9), 1);
      expect(r, DateTime(2025, 5, 12));
    });

    test(
      'sumarDiasHabiles 5 dias desde 30 abril 2025 (incluye 1 mayo festivo)',
      () {
        // Mier 30 abril + 5 habiles, saltando jue 1 may (festivo) y fines de
        // semana: mar 6 mayo? Veamos:
        //   mie 30 abr (inicio, no se cuenta)
        //   jue 1 may festivo (skip)
        //   vie 2 may +1
        //   sab/dom (skip)
        //   lun 5 may +2
        //   mar 6 may +3
        //   mie 7 may +4
        //   jue 8 may +5
        final r = FestivosColombia.sumarDiasHabiles(DateTime(2025, 4, 30), 5);
        expect(r, DateTime(2025, 5, 8));
      },
    );

    test(
      'sumarDiasHabiles 5 dias desde mié 8 ene 2025 (semana sin festivos)',
      () {
        // Festivos cercanos: mié 1 ene y lun 6 ene. Desde mié 8 ene los
        // siguientes 5 días hábiles son jue 9, vie 10, lun 13, mar 14, mié 15
        // (sin festivos en medio).
        final r = FestivosColombia.sumarDiasHabiles(DateTime(2025, 1, 8), 5);
        expect(r, DateTime(2025, 1, 15));
      },
    );

    test('diasHabilesTrasVencimiento: dia de vencimiento no cuenta', () {
      expect(
        FestivosColombia.diasHabilesTrasVencimiento(
          DateTime(2025, 5, 14),
          DateTime(2025, 5, 14),
        ),
        0,
      );
    });

    test('diasHabilesTrasVencimiento: primer dia despues habil suma 1', () {
      expect(
        FestivosColombia.diasHabilesTrasVencimiento(
          DateTime(2025, 5, 13),
          DateTime(2025, 5, 14),
        ),
        1,
      );
    });

    test('diasHabilesTrasVencimiento: salta sabado y domingo', () {
      // Vence vie 9 may 2025; primer dia calendario tras vence: sab 10 (no habil),
      // dom 11 (no), lun 12 (habil). Hasta lun 12 -> 1 dia habil.
      expect(
        FestivosColombia.diasHabilesTrasVencimiento(
          DateTime(2025, 5, 9),
          DateTime(2025, 5, 12),
        ),
        1,
      );
    });
  });
}
