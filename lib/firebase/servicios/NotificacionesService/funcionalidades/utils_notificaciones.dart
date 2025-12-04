/// UTILIDADES PARA NOTIFICACIONES
/// 
/// Contiene métodos auxiliares para formatear mensajes, generar IDs únicos
/// y otras utilidades relacionadas con notificaciones.

import '../../../../utilidades/formato_numeros.dart';

/// Clase que proporciona utilidades para notificaciones
class UtilsNotificaciones {
  
  /// Genera un ID único para notificación basado en el ID del ingreso
  /// Usa hashCode para convertir String a int de forma consistente
  int obtenerIdNotificacion(String ingresoId) {
    // Usar hashCode del string para generar un int único
    // Asegurar que sea positivo para evitar problemas
    return ingresoId.hashCode.abs();
  }
  
  /// Formatea el mensaje de la notificación para ingresos
  String formatearMensajeNotificacion({
    required double monto,
    required String descripcion,
  }) {
    final montoFormateado = FormatoNumeros.formatearParaMostrar(monto);
    
    // Limpiar y truncar descripción si es muy larga
    final descripcionLimpia = _limpiarDescripcion(descripcion);
    
    return 'Es hora de registrar tu ingreso de $montoFormateado por $descripcionLimpia';
  }
  
  /// Limpia y trunca la descripción para que quepa bien en la notificación
  String _limpiarDescripcion(String descripcion) {
    // Limpiar espacios y caracteres especiales
    String limpia = descripcion.trim();
    
    // Truncar si es muy larga (las notificaciones tienen límites)
    if (limpia.length > 50) {
      limpia = '${limpia.substring(0, 47)}...';
    }
    
    return limpia;
  }
  
  /// Genera un título personalizado basado en la frecuencia
  String generarTitulo(String? frecuencia) {
    switch (frecuencia?.toLowerCase()) {
      case 'semanal':
        return '📅 Ingreso Semanal';
      case 'quincenal':
        return '📋 Ingreso Quincenal';
      case 'mensual':
        return '📊 Ingreso Mensual';
      default:
        return '💰 Recordatorio de Ingreso';
    }
  }
  
  /// Convierte una fecha a un formato legible para notificaciones
  String formatearFechaNotificacion(DateTime fecha) {
    final dias = [
      '', 'lunes', 'martes', 'miércoles', 
      'jueves', 'viernes', 'sábado', 'domingo'
    ];
    
    final meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    final diaSemana = dias[fecha.weekday];
    final diaMes = fecha.day;
    final mes = meses[fecha.month];
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    
    return '$diaSemana $diaMes de $mes a las $hora:$minuto';
  }
  
  /// Valida si una fecha es apropiada para programar una notificación
  bool validarFechaNotificacion(DateTime fecha) {
    final ahora = DateTime.now();
    
    // No se puede programar en el pasado
    if (fecha.isBefore(ahora)) {
      return false;
    }
    
    // No programar notificaciones muy lejanas (más de 1 año)
    final unAnoEnElFuturo = ahora.add(const Duration(days: 365));
    if (fecha.isAfter(unAnoEnElFuturo)) {
      return false;
    }
    
    return true;
  }
  
  /// Calcula la próxima fecha de notificación basada en la frecuencia
  DateTime? calcularProximaNotificacion(
    DateTime fechaBase,
    String frecuencia,
    {int horaRecordatorio = 9} // Hora por defecto: 9:00 AM
  ) {
    try {
      // Crear fecha con la hora de recordatorio
      DateTime fechaConHora = DateTime(
        fechaBase.year,
        fechaBase.month,
        fechaBase.day,
        horaRecordatorio,
        0, // minutos
        0, // segundos
      );
      
      // Si la fecha con hora ya pasó hoy, empezar desde mañana
      if (fechaConHora.isBefore(DateTime.now())) {
        fechaConHora = fechaConHora.add(const Duration(days: 1));
      }
      
      // Calcular según la frecuencia
      switch (frecuencia.toLowerCase()) {
        case 'semanal':
          return fechaConHora.add(const Duration(days: 7));
        case 'quincenal':
          return fechaConHora.add(const Duration(days: 15));
        case 'mensual':
          // Agregar un mes manteniendo el día
          return DateTime(
            fechaConHora.year,
            fechaConHora.month + 1,
            fechaConHora.day,
            fechaConHora.hour,
            fechaConHora.minute,
          );
        default:
          return null;
      }
    } catch (e) {
      print('Error calculando próxima notificación: $e');
      return null;
    }
  }
  
  /// Obtiene un emoji apropiado para el tipo de ingreso
  String obtenerEmojiCategoria(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case 'salario':
      case 'sueldo':
        return '💼';
      case 'freelance':
      case 'independiente':
        return '🎯';
      case 'inversion':
      case 'inversiones':
        return '📈';
      case 'alquiler':
        return '🏠';
      case 'venta':
      case 'ventas':
        return '🛍️';
      case 'regalo':
      case 'regalos':
        return '🎁';
      default:
        return '💰';
    }
  }
}