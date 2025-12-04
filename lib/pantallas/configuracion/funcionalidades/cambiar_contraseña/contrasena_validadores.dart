/// Clase que contiene los validadores para los campos de contraseña
class ContrasenaValidadores {
  
  /// Valida la contraseña actual
  static String? validarContrasenaActual(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña actual';
    }
    return null;
  }

  /// Valida la nueva contraseña
  static String? validarNuevaContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa la nueva contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  /// Valida la confirmación de contraseña
  static String? validarConfirmacionContrasena(String? value, String nuevaContrasena) {
    if (value == null || value.isEmpty) {
      return 'Confirma la nueva contraseña';
    }
    if (value != nuevaContrasena) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Verifica si la contraseña es segura
  static bool esContrasenaSegura(String contrasena) {
    if (contrasena.length < 8) return false;
    
    bool tieneLetra = contrasena.contains(RegExp(r'[a-zA-Z]'));
    bool tieneNumero = contrasena.contains(RegExp(r'[0-9]'));
    bool tieneCaracterEspecial = contrasena.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return tieneLetra && tieneNumero && tieneCaracterEspecial;
  }

  /// Obtiene el nivel de seguridad de una contraseña
  static String obtenerNivelSeguridad(String contrasena) {
    if (contrasena.length < 6) return 'Débil';
    if (contrasena.length < 8) return 'Regular';
    if (esContrasenaSegura(contrasena)) return 'Fuerte';
    return 'Regular';
  }
}