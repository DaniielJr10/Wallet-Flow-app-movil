/// Funciones utilitarias y helpers para la pantalla de ahorros.
class UtilsAhorros {
  static String formatearMoneda(double cantidad) {
    // Implementar formateo de moneda
    return cantidad.toString();
  }

  static String formatearFecha(DateTime fecha) {
    // Implementar formateo de fecha
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
