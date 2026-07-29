/// Reglas de validación del cliente.
///
/// Estas reglas son un **espejo** de las que el servidor ya impone con
/// Pydantic; no la reemplazan. La validación del cliente no es un control de
/// seguridad —quien ataca controla el cliente y puede saltárselo con `curl`—,
/// existe para dar retroalimentación inmediata y no gastar un viaje de red en
/// decir algo obvio, que en una escuela con señal intermitente cuesta caro.
///
/// **Regla de oro: el cliente nunca puede ser MÁS estricto que el servidor.**
/// Si lo fuera, rechazaría entradas que el servidor aceptaría y bloquearía a
/// usuarios legítimos. El caso concreto que motivó esta advertencia: el
/// servidor exige 12 caracteres al registrar un usuario
/// (`RegisterUserRequest`), pero solo 8 al registrar la institución
/// (`RegisterInstitutionRequest.admin_password`), y **ninguno** al iniciar sesión
/// (`LoginRequest.password` no declara restricción). Poner 12 en la pantalla
/// de acceso dejaría fuera a cualquier administrador dado de alta con 8.
///
/// Cada constante cita el archivo del que sale. Si alguien cambia el servidor
/// y no cambia esto, la prueba `test_reglas_cliente_espejo.py` del backend
/// falla — está justamente para que la divergencia no pase inadvertida.
library;

class InputRules {
  InputRules._();

  // --- api/api/v1/auth/schemas.py -----------------------------------------
  /// `RegisterUserRequest.password = Field(min_length=12, max_length=128)`
  static const int passwordMinRegistro = 12;
  static const int passwordMax = 128;

  /// `InstitutionRegister.admin_password = Field(..., min_length=8)`
  /// en `api/api/v1/institutions/schemas.py`.
  static const int passwordMinInstitucion = 8;

  /// `LoginRequest.device_info = Field(default=None, max_length=200)`
  static const int deviceInfoMax = 200;

  // --- api/api/v1/institutions/schemas.py ---------------------------------
  /// `school_name = Field(..., min_length=2)`
  static const int nombreEscuelaMin = 2;

  // --- api/application/dtos/student_dto.py --------------------------------
  /// `full_name = Field(min_length=1, max_length=180)`
  static const int nombreAlumnoMin = 1;
  static const int nombreAlumnoMax = 180;

  /// `birth_year = Field(default=None, ge=2008, le=2022)`
  static const int anioNacimientoMin = 2008;
  static const int anioNacimientoMax = 2022;

  // --- api/api/v1/groups/schemas.py ---------------------------------------
  /// `grade = Field(ge=1, le=6)` — 1° a 6° de primaria.
  static const int gradoMin = 1;
  static const int gradoMax = 6;

  /// `group_label = Field(min_length=1, max_length=16)`
  static const int etiquetaGrupoMax = 16;

  /// `RejectInstitutionRequest.reason = Field(default=None, max_length=500)`
  /// en `api/api/v1/institutions/schemas.py`. Vivía como literal
  /// `maxLength: 500` dentro de `institutions_approval_screen.dart`, fuera del
  /// alcance del guardián anti-divergencia; se movió aquí para que también
  /// quede cubierto por `test_reglas_cliente_espejo.py`.
  static const int motivoRechazoMax = 500;

  // --- Tarjeta bancaria ----------------------------------------------------
  /// Estos límites **no** son espejo de un esquema de Pydantic: el número de
  /// tarjeta nunca llega a nuestro backend. Viaja del dispositivo directo a
  /// Conekta (`conekta_tokenization_datasource.dart`) y lo único que después
  /// recibe la API es el `token_id` de un solo uso
  /// (`CardCheckoutRequest.token_id`). Por eso la única validación previa
  /// posible es la del cliente, y por eso vale la pena que sea real: un
  /// número mal tecleado que se detecta aquí ahorra un viaje a la pasarela y
  /// un mensaje de error genérico devuelto por un tercero.
  ///
  /// Rango de longitudes de la norma ISO/IEC 7812 (13 dígitos de algunas Visa
  /// antiguas hasta 19 de Maestro/UnionPay).
  static const int tarjetaMinDigitos = 13;
  static const int tarjetaMaxDigitos = 19;

  /// 3 dígitos en Visa/Mastercard/Carnet, 4 en American Express.
  static const int cvcMin = 3;
  static const int cvcMax = 4;
}

/// Validadores para usar en el parámetro `validator:` de un `TextFormField`.
///
/// Devuelven `null` cuando el valor es aceptable y el mensaje de error cuando
/// no lo es, que es el contrato que espera Flutter.
class Validators {
  Validators._();

  /// Campo obligatorio. Es el validador que más trabajo hace: la mayoría de
  /// los 422 evitables vienen de mandar un campo vacío.
  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  /// Correo electrónico.
  ///
  /// La comprobación es **deliberadamente permisiva**: el servidor usa
  /// `EmailStr`, respaldado por `email-validator`, que acepta direcciones más
  /// raras de lo que una expresión regular corta suele contemplar (subdominios
  /// largos, caracteres poco frecuentes en la parte local). Una regex estricta
  /// acá rechazaría correos que el servidor sí acepta. Solo se descartan los
  /// casos evidentes: vacío, sin arroba, sin dominio o con espacios.
  static String? correo(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'El correo es obligatorio';
    if (v.contains(' ')) return 'El correo no puede tener espacios';

    final partes = v.split('@');
    if (partes.length != 2 || partes[0].isEmpty || partes[1].isEmpty) {
      return 'Escribe un correo válido, como nombre@escuela.mx';
    }
    if (!partes[1].contains('.') || partes[1].endsWith('.')) {
      return 'Al correo le falta el dominio, como @escuela.mx';
    }
    return null;
  }

  /// Contraseña al **iniciar sesión**.
  ///
  /// Solo comprueba que no esté vacía. `LoginRequest.password` no declara
  /// longitud mínima a propósito: exigirla acá dejaría fuera a las cuentas
  /// creadas con la regla de 8 caracteres del registro de institución.
  static String? passwordAcceso(String? valor) {
    if (valor == null || valor.isEmpty) return 'La contraseña es obligatoria';
    return null;
  }

  /// Contraseña al **crear una cuenta**. Refleja `min_length=12`.
  ///
  /// No se exige mezcla de mayúsculas, dígitos y símbolos, igual que en el
  /// servidor: NIST SP 800-63B desaconseja esas reglas de composición porque
  /// empujan a patrones predecibles del tipo `Password1!`, y privilegia la
  /// longitud.
  static String? passwordNueva(String? valor, {int? minimo}) {
    final min = minimo ?? InputRules.passwordMinRegistro;
    final v = valor ?? '';
    if (v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length < min) {
      return 'Debe tener al menos $min caracteres (van ${v.length})';
    }
    if (v.length > InputRules.passwordMax) {
      return 'No puede pasar de ${InputRules.passwordMax} caracteres';
    }
    return null;
  }

  /// Longitud máxima genérica, para reflejar los `max_length` del servidor.
  static String? largoMaximo(String? valor, int maximo, {String campo = 'Este campo'}) {
    if (valor != null && valor.trim().length > maximo) {
      return '$campo no puede pasar de $maximo caracteres';
    }
    return null;
  }

  /// Nombre completo del alumno.
  static String? nombreAlumno(String? valor) {
    return requerido(valor, campo: 'El nombre') ??
        largoMaximo(valor, InputRules.nombreAlumnoMax, campo: 'El nombre');
  }

  /// Nombre de la escuela.
  static String? nombreEscuela(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'El nombre de la escuela es obligatorio';
    if (v.length < InputRules.nombreEscuelaMin) {
      return 'Debe tener al menos ${InputRules.nombreEscuelaMin} caracteres';
    }
    return null;
  }

  /// Motivo por el que el SUPERADMIN rechaza una institución. Opcional, pero
  /// acotado: el texto viaja al correo del solicitante.
  static String? motivoRechazo(String? valor) {
    return largoMaximo(valor, InputRules.motivoRechazoMax, campo: 'El motivo');
  }

  /// Número de tarjeta: longitud ISO/IEC 7812 más **algoritmo de Luhn**.
  ///
  /// Luhn es una suma de verificación, no un control de seguridad: detecta
  /// dígitos mal tecleados o transpuestos (`4242` por `4422`), que es la causa
  /// real de la mayoría de los pagos rechazados. No prueba que la tarjeta
  /// exista ni que tenga fondos; eso solo lo sabe la pasarela.
  static String? tarjeta(String? valor) {
    final digitos = (valor ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digitos.isEmpty) return 'El número de tarjeta es obligatorio';
    if (!RegExp(r'^\d+$').hasMatch(digitos)) {
      return 'El número de tarjeta solo puede tener dígitos';
    }
    if (digitos.length < InputRules.tarjetaMinDigitos ||
        digitos.length > InputRules.tarjetaMaxDigitos) {
      return 'Debe tener entre ${InputRules.tarjetaMinDigitos} y '
          '${InputRules.tarjetaMaxDigitos} dígitos';
    }
    if (!pasaLuhn(digitos)) return 'El número de tarjeta no es válido';
    return null;
  }

  /// Algoritmo de Luhn (ISO/IEC 7812-1), de derecha a izquierda: se duplica
  /// cada segundo dígito y, si el doble pasa de 9, se le restan 9 (equivale a
  /// sumar sus dos cifras). La tarjeta es válida si el total es múltiplo de 10.
  ///
  /// Público para que la prueba unitaria pueda ejercitarlo con los números de
  /// prueba oficiales sin pasar por el mensaje de error.
  static bool pasaLuhn(String digitos) {
    var suma = 0;
    var duplicar = false;
    for (var i = digitos.length - 1; i >= 0; i--) {
      var d = digitos.codeUnitAt(i) - 0x30;
      if (duplicar) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      suma += d;
      duplicar = !duplicar;
    }
    return suma % 10 == 0;
  }

  /// Vencimiento en formato `MM/AA`.
  ///
  /// Comprueba el formato, que el mes exista y que la tarjeta no esté vencida.
  /// La versión anterior solo validaba el formato con
  /// `RegExp(r'^\d{2}/\d{2}$')`, así que aceptaba `99/99` y cualquier fecha ya
  /// pasada. `ahora` se inyecta para que la prueba no dependa del reloj.
  static String? vencimientoTarjeta(String? valor, {DateTime? ahora}) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'El vencimiento es obligatorio';
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) return 'Usa el formato MM/AA';

    final mes = int.parse(v.substring(0, 2));
    final anio = 2000 + int.parse(v.substring(3, 5));
    if (mes < 1 || mes > 12) return 'El mes debe estar entre 01 y 12';

    // La tarjeta sigue siendo válida durante todo su mes de vencimiento, así
    // que se compara contra el primer día del mes siguiente.
    final hoy = ahora ?? DateTime.now();
    final vence = DateTime(anio, mes + 1, 1);
    if (!vence.isAfter(DateTime(hoy.year, hoy.month, hoy.day))) {
      return 'La tarjeta ya venció';
    }
    return null;
  }

  /// Código de seguridad: 3 o 4 dígitos según la marca.
  static String? cvc(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'El CVC es obligatorio';
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'El CVC solo puede tener dígitos';
    if (v.length < InputRules.cvcMin || v.length > InputRules.cvcMax) {
      return 'El CVC debe tener ${InputRules.cvcMin} o ${InputRules.cvcMax} dígitos';
    }
    return null;
  }

  /// Encadena varios validadores y devuelve el primer error.
  static String? Function(String?) combinar(List<String? Function(String?)> reglas) {
    return (valor) {
      for (final regla in reglas) {
        final error = regla(valor);
        if (error != null) return error;
      }
      return null;
    };
  }
}
