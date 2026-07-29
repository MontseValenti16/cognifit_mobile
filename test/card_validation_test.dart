import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/core/validation/input_rules.dart';

void main() {
  group('Algoritmo de Luhn', () {
    test('acepta los números de prueba oficiales de las marcas', () {
      const validos = [
        '4242424242424242',
        '4000056655665556',
        '5555555555554444',
        '2223003122003222',
        '378282246310005',
        '6011111111111117',
        '4917300800000000',
      ];
      for (final numero in validos) {
        expect(Validators.pasaLuhn(numero), isTrue, reason: '$numero debería pasar Luhn');
        expect(Validators.tarjeta(numero), isNull, reason: '$numero debería ser aceptado');
      }
    });

    test('rechaza un dígito mal tecleado', () {
      expect(Validators.pasaLuhn('4242424242424243'), isFalse);
      expect(Validators.tarjeta('4242424242424243'), 'El número de tarjeta no es válido');
    });

    test('rechaza dos dígitos transpuestos', () {
      expect(Validators.pasaLuhn('4224424242424242'), isFalse);
    });

    test('ignora espacios y guiones al validar', () {
      expect(Validators.tarjeta('4242 4242 4242 4242'), isNull);
      expect(Validators.tarjeta('4242-4242-4242-4242'), isNull);
    });
  });

  group('Validators.tarjeta', () {
    test('exige el campo', () {
      expect(Validators.tarjeta(null), 'El número de tarjeta es obligatorio');
      expect(Validators.tarjeta('   '), 'El número de tarjeta es obligatorio');
    });

    test('rechaza letras', () {
      expect(Validators.tarjeta('4242abcd42424242'), 'El número de tarjeta solo puede tener dígitos');
    });

    test('rechaza longitudes fuera de la norma ISO/IEC 7812', () {
      expect(Validators.tarjeta('424242424242'), contains('dígitos'));
      expect(Validators.tarjeta('42424242424242424242'), contains('dígitos'));
    });
  });

  group('Validators.vencimientoTarjeta', () {
    final ahora = DateTime(2026, 7, 27);

    test('acepta una fecha futura', () {
      expect(Validators.vencimientoTarjeta('12/28', ahora: ahora), isNull);
    });

    test('acepta el mes en curso: la tarjeta vence al final del mes', () {
      expect(Validators.vencimientoTarjeta('07/26', ahora: ahora), isNull);
    });

    test('rechaza una tarjeta ya vencida', () {
      expect(Validators.vencimientoTarjeta('06/26', ahora: ahora), 'La tarjeta ya venció');
      expect(Validators.vencimientoTarjeta('01/20', ahora: ahora), 'La tarjeta ya venció');
    });

    test('rechaza un mes inexistente', () {
      expect(Validators.vencimientoTarjeta('99/99', ahora: ahora), 'El mes debe estar entre 01 y 12');
      expect(Validators.vencimientoTarjeta('00/28', ahora: ahora), 'El mes debe estar entre 01 y 12');
    });

    test('exige el formato MM/AA', () {
      expect(Validators.vencimientoTarjeta('1228', ahora: ahora), 'Usa el formato MM/AA');
      expect(Validators.vencimientoTarjeta('12/2028', ahora: ahora), 'Usa el formato MM/AA');
      expect(Validators.vencimientoTarjeta(null, ahora: ahora), 'El vencimiento es obligatorio');
    });
  });

  group('Validators.cvc', () {
    test('acepta 3 y 4 dígitos', () {
      expect(Validators.cvc('123'), isNull);
      expect(Validators.cvc('1234'), isNull);
    });

    test('rechaza longitudes fuera de rango', () {
      expect(Validators.cvc('12'), contains('dígitos'));
      expect(Validators.cvc('12345'), contains('dígitos'));
    });

    test('rechaza no dígitos y campo vacío', () {
      expect(Validators.cvc('12a'), 'El CVC solo puede tener dígitos');
      expect(Validators.cvc(''), 'El CVC es obligatorio');
    });
  });

  group('Validators.motivoRechazo', () {
    test('acepta vacío: el motivo es opcional', () {
      expect(Validators.motivoRechazo(null), isNull);
      expect(Validators.motivoRechazo(''), isNull);
    });

    test('acepta exactamente el máximo del servidor', () {
      expect(Validators.motivoRechazo('a' * InputRules.motivoRechazoMax), isNull);
    });

    test('rechaza un carácter más', () {
      expect(Validators.motivoRechazo('a' * (InputRules.motivoRechazoMax + 1)), contains('500'));
    });
  });
}
