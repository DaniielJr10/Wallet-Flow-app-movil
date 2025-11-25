// Funciones utilitarias para cuentas (colores, iconos, helpers)
// Implementa aquí funciones de utilidad

import 'package:flutter/material.dart';

class UtilsCuentas {
  // Ejemplo de función utilitaria
  static Color obtenerColorTipoCuenta(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return const Color(0xFF10B981);
      case 'corriente':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
