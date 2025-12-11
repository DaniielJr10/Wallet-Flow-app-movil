/// Constantes y configuraciones para las notificaciones de deudas
class ConfiguracionNotificacionesDeudas {
  // IDs de canales de notificación
  static const String canalVencimiento = 'deudas_vencimiento';
  static const String canalInmediatas = 'deudas_inmediatas';
  static const String canalUrgentes = 'deudas_urgentes';

  // Nombres de canales
  static const String nombreCanalVencimiento = 'Vencimiento de Deudas';
  static const String nombreCanalInmediatas = 'Alertas de Deudas';
  static const String nombreCanalUrgentes = 'Deudas Urgentes';

  // Descripciones de canales
  static const String descripcionCanalVencimiento = 'Notificaciones cuando las deudas están por vencer';
  static const String descripcionCanalInmediatas = 'Notificaciones inmediatas sobre deudas';
  static const String descripcionCanalUrgentes = 'Alertas críticas de deudas que vencen pronto';

  // Configuración de días de anticipación
  static const List<int> diasAnticipacionPorDefecto = [7, 3, 1];
  static const List<int> diasAnticipacionPersonalizado = [14, 7, 3, 1];

  // Colores para las notificaciones
  static const int colorNotificacion = 0xFFFF5722; // Deep Orange
  static const int colorUrgente = 0xFFD32F2F; // Red 700
  static const int colorAdvertencia = 0xFFFF9800; // Orange

  // Iconos por defecto
  static const String iconoPorDefecto = '@mipmap/ic_launcher';

  // Límites y configuraciones
  static const int limiteNotificacionesPorDeuda = 3;
  static const int multiplicadorIdNotificacion = 100;
  static const int multiplicadorIdInmediata = 1000;

  // Mensajes por defecto
  static const String tituloVencimiento = '⚠️ Deuda próxima a vencer';
  static const String tituloUrgente = '🚨 Deuda vence HOY';
  static const String tituloVencida = '❌ Deuda vencida';

  // Configuración de horarios
  static const int horaNotificacion = 9; // 9:00 AM por defecto
  static const int minutoNotificacion = 0;

  /// Genera el cuerpo del mensaje para una notificación de vencimiento
  static String generarCuerpoVencimiento(String nombreDeuda, double monto, int dias) {
    if (dias == 0) {
      return '$nombreDeuda vence HOY\nMonto: \$${monto.toStringAsFixed(2)}';
    } else if (dias == 1) {
      return '$nombreDeuda vence mañana\nMonto: \$${monto.toStringAsFixed(2)}';
    } else {
      return '$nombreDeuda vence en $dias días\nMonto: \$${monto.toStringAsFixed(2)}';
    }
  }

  /// Genera el cuerpo del mensaje para una deuda vencida
  static String generarCuerpoVencida(String nombreDeuda, double monto, int diasVencida) {
    if (diasVencida == 1) {
      return '$nombreDeuda venció ayer\nMonto: \$${monto.toStringAsFixed(2)}';
    } else {
      return '$nombreDeuda venció hace $diasVencida días\nMonto: \$${monto.toStringAsFixed(2)}';
    }
  }

  /// Obtiene el título apropiado según los días restantes
  static String obtenerTitulo(int diasRestantes) {
    if (diasRestantes < 0) {
      return tituloVencida;
    } else if (diasRestantes == 0) {
      return tituloUrgente;
    } else {
      return tituloVencimiento;
    }
  }

  /// Obtiene el color apropiado según los días restantes
  static int obtenerColor(int diasRestantes) {
    if (diasRestantes < 0) {
      return colorUrgente;
    } else if (diasRestantes <= 1) {
      return colorUrgente;
    } else {
      return colorAdvertencia;
    }
  }
}

/// Utilidades para el manejo de fechas en notificaciones
class UtilidadesFechasNotificaciones {
  /// Convierte una fecha a la hora específica para notificaciones
  static DateTime ajustarHoraNotificacion(DateTime fecha) {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      ConfiguracionNotificacionesDeudas.horaNotificacion,
      ConfiguracionNotificacionesDeudas.minutoNotificacion,
    );
  }

  /// Calcula las fechas de notificación basadas en la fecha de vencimiento
  static List<DateTime> calcularFechasNotificacion(
    DateTime fechaVencimiento,
    List<int> diasAnticipacion,
  ) {
    final fechas = <DateTime>[];
    final ahora = DateTime.now();

    for (final dias in diasAnticipacion) {
      final fechaNotificacion = fechaVencimiento.subtract(Duration(days: dias));
      final fechaAjustada = ajustarHoraNotificacion(fechaNotificacion);
      
      // Solo agregar fechas futuras
      if (fechaAjustada.isAfter(ahora)) {
        fechas.add(fechaAjustada);
      }
    }

    return fechas;
  }

  /// Formatea una fecha para mostrarla en la interfaz
  static String formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora).inDays;

    if (diferencia == 0) {
      return 'Hoy';
    } else if (diferencia == 1) {
      return 'Mañana';
    } else if (diferencia == -1) {
      return 'Ayer';
    } else if (diferencia > 1) {
      return 'En $diferencia días';
    } else {
      return 'Hace ${diferencia.abs()} días';
    }
  }

  /// Verifica si una fecha está en el rango de notificación
  static bool estaEnRangoNotificacion(DateTime fechaVencimiento, int diasMaximos) {
    final ahora = DateTime.now();
    final diferencia = fechaVencimiento.difference(ahora).inDays;
    return diferencia >= -7 && diferencia <= diasMaximos; // Incluye 7 días vencida
  }
}

/// Enumeración para los tipos de prioridad de notificaciones
enum PrioridadNotificacion {
  baja,
  normal,
  alta,
  critica;

  /// Obtiene la prioridad basada en los días restantes
  static PrioridadNotificacion obtenerPrioridad(int diasRestantes) {
    if (diasRestantes < 0) {
      return PrioridadNotificacion.critica;
    } else if (diasRestantes == 0) {
      return PrioridadNotificacion.critica;
    } else if (diasRestantes == 1) {
      return PrioridadNotificacion.alta;
    } else if (diasRestantes <= 3) {
      return PrioridadNotificacion.normal;
    } else {
      return PrioridadNotificacion.baja;
    }
  }
}

/// Configuración de estilos para las notificaciones
class EstilosNotificacion {
  /// Obtiene el emoji apropiado para la notificación
  static String obtenerEmoji(int diasRestantes) {
    if (diasRestantes < 0) {
      return '❌';
    } else if (diasRestantes == 0) {
      return '🚨';
    } else if (diasRestantes <= 1) {
      return '⏰';
    } else {
      return '⚠️';
    }
  }

  /// Genera el título completo con emoji
  static String generarTituloCompleto(int diasRestantes) {
    final emoji = obtenerEmoji(diasRestantes);
    final titulo = ConfiguracionNotificacionesDeudas.obtenerTitulo(diasRestantes);
    return '$emoji $titulo';
  }
}
