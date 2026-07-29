library;

class InputRules {
  InputRules._();

  static const int passwordMinRegistro = 12;
  static const int passwordMax = 128;

  static const int passwordMinInstitucion = 8;

  static const int deviceInfoMax = 200;

  static const int nombreEscuelaMin = 2;

  static const int nombreAlumnoMin = 1;
  static const int nombreAlumnoMax = 180;

  static const int anioNacimientoMin = 2008;
  static const int anioNacimientoMax = 2022;

  static const int gradoMin = 1;
  static const int gradoMax = 6;

  static const int etiquetaGrupoMax = 16;

  static const int motivoRechazoMax = 500;

  static const int tarjetaMinDigitos = 13;
  static const int tarjetaMaxDigitos = 19;

  static const int cvcMin = 3;
  static const int cvcMax = 4;
}

class Validators {
  Validators._();

  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

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

  static String? passwordAcceso(String? valor) {
    if (valor == null || valor.isEmpty) return 'La contraseña es obligatoria';
    return null;
  }

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

  static String? largoMaximo(String? valor, int maximo, {String campo = 'Este campo'}) {
    if (valor != null && valor.trim().length > maximo) {
      return '$campo no puede pasar de $maximo caracteres';
    }
    return null;
  }

  static String? nombreAlumno(String? valor) {
    return requerido(valor, campo: 'El nombre') ??
        largoMaximo(valor, InputRules.nombreAlumnoMax, campo: 'El nombre');
  }

  static String? nombreEscuela(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'El nombre de la escuela es obligatorio';
    if (v.length < InputRules.nombreEscuelaMin) {
      return 'Debe tener al menos ${InputRules.nombreEscuelaMin} caracteres';
    }
    return null;
  }

  static String? motivoRechazo(String? valor) {
    return largoMaximo(valor, InputRules.motivoRechazoMax, campo: 'El motivo');
  }

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

  static String? vencimientoTarjeta(String? valor, {DateTime? ahora}) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'El vencimiento es obligatorio';
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) return 'Usa el formato MM/AA';

    final mes = int.parse(v.substring(0, 2));
    final anio = 2000 + int.parse(v.substring(3, 5));
    if (mes < 1 || mes > 12) return 'El mes debe estar entre 01 y 12';

    final hoy = ahora ?? DateTime.now();
    final vence = DateTime(anio, mes + 1, 1);
    if (!vence.isAfter(DateTime(hoy.year, hoy.month, hoy.day))) {
      return 'La tarjeta ya venció';
    }
    return null;
  }

  static String? cvc(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'El CVC es obligatorio';
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'El CVC solo puede tener dígitos';
    if (v.length < InputRules.cvcMin || v.length > InputRules.cvcMax) {
      return 'El CVC debe tener ${InputRules.cvcMin} o ${InputRules.cvcMax} dígitos';
    }
    return null;
  }

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
