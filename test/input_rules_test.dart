/// La validación del cliente es un espejo de la del servidor, nunca su
/// reemplazo. Estas pruebas fijan sobre todo que **no sea más estricta**: un
/// validador que rechaza lo que el servidor aceptaría bloquea a usuarios
/// legítimos, que es peor que no validar.
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/core/validation/input_rules.dart';

void main() {
  group('correo', () {
    test('acepta los correos normales', () {
      for (final c in [
        'docente@escuela.mx',
        'director@primaria.edu.mx',
        'a.b+etiqueta@sub.dominio.org',
      ]) {
        expect(Validators.correo(c), isNull, reason: '$c debería aceptarse');
      }
    });

    test('rechaza solo lo evidente', () {
      expect(Validators.correo(''), isNotNull);
      expect(Validators.correo('sinarroba.mx'), isNotNull);
      expect(Validators.correo('sin@dominio'), isNotNull);
      expect(Validators.correo('con espacio@x.mx'), isNotNull);
    });

    test('no es más estricto que el servidor', () {
      // email-validator acepta estas formas; una regex corta suele romperlas.
      expect(Validators.correo('nombre_apellido@escuela-primaria.gob.mx'), isNull);
      expect(Validators.correo('x@y.zz'), isNull);
    });
  });

  group('contraseña', () {
    test('al iniciar sesión solo se exige que no esté vacía', () {
      // LoginRequest.password no declara mínimo: una cuenta creada con la
      // regla de 8 del registro de institución debe poder entrar.
      expect(Validators.passwordAcceso('12345678'), isNull);
      expect(Validators.passwordAcceso('corta'), isNull);
      expect(Validators.passwordAcceso(''), isNotNull);
    });

    test('al registrar refleja el mínimo de 12', () {
      expect(InputRules.passwordMinRegistro, 12);
      expect(Validators.passwordNueva('123456789012'), isNull);
      expect(Validators.passwordNueva('12345678901'), isNotNull);
    });

    test('la institución usa su propio mínimo de 8', () {
      expect(InputRules.passwordMinInstitucion, 8);
      final v = Validators.passwordNueva('12345678',
          minimo: InputRules.passwordMinInstitucion);
      expect(v, isNull);
    });

    test('el mensaje dice cuántos caracteres faltan', () {
      expect(Validators.passwordNueva('abc'), contains('van 3'));
    });

    test('respeta el máximo de 128', () {
      expect(Validators.passwordNueva('a' * 129), isNotNull);
      expect(Validators.passwordNueva('a' * 128), isNull);
    });
  });

  group('otros campos', () {
    test('nombre de escuela: mínimo 2', () {
      expect(Validators.nombreEscuela('A'), isNotNull);
      expect(Validators.nombreEscuela('Benito Juárez'), isNull);
    });

    test('nombre de alumno: máximo 180', () {
      expect(Validators.nombreAlumno('a' * 181), isNotNull);
      expect(Validators.nombreAlumno('Ana López'), isNull);
    });

    test('requerido ignora los espacios en blanco', () {
      expect(Validators.requerido('   '), isNotNull);
      expect(Validators.requerido(' x '), isNull);
    });

    test('combinar devuelve el primer error', () {
      final v = Validators.combinar([
        (s) => Validators.requerido(s, campo: 'El campo'),
        (s) => Validators.largoMaximo(s, 5),
      ]);
      expect(v(''), contains('obligatorio'));
      expect(v('123456'), contains('5 caracteres'));
      expect(v('ok'), isNull);
    });
  });
}
