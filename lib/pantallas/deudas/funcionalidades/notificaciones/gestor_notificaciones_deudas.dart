import 'package:flutter/foundation.dart';
import 'servicio_notificaciones_deudas.dart';

/// Modelo para representar una deuda en el contexto de notificaciones
class DeudaNotificacion {
  final int id;
  final String nombre;
  final double monto;
  final DateTime fechaVencimiento;
  final bool activa;

  DeudaNotificacion({
    required this.id,
    required this.nombre,
    required this.monto,
    required this.fechaVencimiento,
    this.activa = true,
  });

  /// Calcula los días restantes hasta el vencimiento
  int get diasRestantes {
    final diferencia = fechaVencimiento.difference(DateTime.now());
    return diferencia.inDays;
  }

  /// Verifica si la deuda está próxima a vencer
  bool get proximaAVencer {
    return diasRestantes <= 7 && diasRestantes >= 0;
  }

  /// Verifica si la deuda ya venció
  bool get vencida {
    return diasRestantes < 0;
  }
}

/// Gestor principal para las notificaciones de deudas
class GestorNotificacionesDeudas {
  static final GestorNotificacionesDeudas _instancia = GestorNotificacionesDeudas._internal();
  factory GestorNotificacionesDeudas() => _instancia;
  GestorNotificacionesDeudas._internal();

  final ServicioNotificacionesDeudas _servicioNotificaciones = ServicioNotificacionesDeudas();

  /// Lista de deudas actualmente monitoreadas
  final List<DeudaNotificacion> _deudasMonitoreadas = [];

  /// Configuración de días de anticipación para las notificaciones
  static const List<int> diasAnticipacionPorDefecto = [7, 3, 1];

  static bool _inicializado = false;

  /// Asegura que el gestor esté inicializado antes de cualquier operación
  Future<void> _asegurarInicializacion() async {
    if (_inicializado) return;
    
    await ServicioNotificacionesDeudas.inicializar();
    _inicializado = true;
    
    if (kDebugMode) {
      print('✅ Gestor de notificaciones de deudas inicializado automáticamente');
    }
  }

  /// Inicializa el gestor de notificaciones (método público opcional)
  Future<void> inicializar() async {
    await _asegurarInicializacion();
  }

  /// Agrega una nueva deuda al sistema de notificaciones
  Future<void> agregarDeuda(DeudaNotificacion deuda) async {
    await _asegurarInicializacion();
    
    // Remover la deuda si ya existe
    _deudasMonitoreadas.removeWhere((d) => d.id == deuda.id);
    
    // Agregar la nueva deuda
    _deudasMonitoreadas.add(deuda);

    // Programar notificaciones si la deuda está activa
    if (deuda.activa) {
      await _programarNotificacionesParaDeuda(deuda);
    }

    if (kDebugMode) {
      print('✅ Deuda agregada al sistema de notificaciones: ${deuda.nombre}');
    }
  }

  /// Actualiza una deuda existente
  Future<void> actualizarDeuda(DeudaNotificacion deudaActualizada) async {
    await _asegurarInicializacion();
    
    final indice = _deudasMonitoreadas.indexWhere((d) => d.id == deudaActualizada.id);
    
    if (indice != -1) {
      // Cancelar notificaciones existentes
      await _servicioNotificaciones.cancelarNotificacionesDeuda(deudaActualizada.id);
      
      // Actualizar la deuda
      _deudasMonitoreadas[indice] = deudaActualizada;
      
      // Reprogramar notificaciones si está activa
      if (deudaActualizada.activa) {
        await _programarNotificacionesParaDeuda(deudaActualizada);
      }

      if (kDebugMode) {
        print('✅ Deuda actualizada: ${deudaActualizada.nombre}');
      }
    }
  }

  /// Elimina una deuda del sistema de notificaciones
  Future<void> eliminarDeuda(int idDeuda) async {
    // Cancelar todas las notificaciones de la deuda
    await _servicioNotificaciones.cancelarNotificacionesDeuda(idDeuda);
    
    // Remover de la lista
    _deudasMonitoreadas.removeWhere((d) => d.id == idDeuda);

    if (kDebugMode) {
      print('Deuda eliminada del sistema de notificaciones: $idDeuda');
    }
  }

  /// Programa notificaciones para una deuda específica
  Future<void> _programarNotificacionesParaDeuda(DeudaNotificacion deuda) async {
    // Solo programar si la fecha de vencimiento es en el futuro
    if (deuda.fechaVencimiento.isBefore(DateTime.now())) {
      if (kDebugMode) {
        print('No se programan notificaciones para deuda vencida: ${deuda.nombre}');
      }
      return;
    }

    await _servicioNotificaciones.programarNotificacionesMultiples(
      idBase: deuda.id * 100, // Multiplicar por 100 para evitar conflictos
      nombreDeuda: deuda.nombre,
      monto: deuda.monto,
      fechaVencimiento: deuda.fechaVencimiento,
      diasAnticipacion: diasAnticipacionPorDefecto,
    );

    if (kDebugMode) {
      print('Notificaciones programadas para: ${deuda.nombre}');
    }
  }

  /// Obtiene las deudas próximas a vencer
  List<DeudaNotificacion> get deudasProximasAVencer {
    return _deudasMonitoreadas.where((deuda) => 
      deuda.activa && deuda.proximaAVencer
    ).toList()
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
  }

  /// Obtiene las deudas vencidas
  List<DeudaNotificacion> get deudasVencidas {
    return _deudasMonitoreadas.where((deuda) => 
      deuda.activa && deuda.vencida
    ).toList()
      ..sort((a, b) => b.diasRestantes.compareTo(a.diasRestantes));
  }

  /// Obtiene todas las deudas monitoreadas
  List<DeudaNotificacion> get todasLasDeudas => List.unmodifiable(_deudasMonitoreadas);

  /// Verifica el estado de las deudas y muestra notificaciones inmediatas si es necesario
  Future<void> verificarEstadoDeudas() async {
    await _asegurarInicializacion();
    
    final deudasUrgentes = _deudasMonitoreadas.where((deuda) =>
      deuda.activa && deuda.diasRestantes == 0
    ).toList();

    for (final deuda in deudasUrgentes) {
      await _servicioNotificaciones.mostrarNotificacionInmediata(
        id: deuda.id * 1000, // ID único para notificaciones inmediatas
        titulo: '🚨 Deuda vence HOY',
        cuerpo: '${deuda.nombre} - \$${deuda.monto.toStringAsFixed(2)}',
        payload: 'deuda_urgente_${deuda.id}',
      );
    }

    if (kDebugMode && deudasUrgentes.isNotEmpty) {
      print('📱 Se enviaron ${deudasUrgentes.length} notificaciones urgentes');
    }
  }

  /// Actualiza masivamente las deudas desde una fuente externa
  Future<void> actualizarDeudasMasivamente(List<DeudaNotificacion> nuevasDeudas) async {
    // Cancelar todas las notificaciones existentes
    await _servicioNotificaciones.cancelarTodasLasNotificaciones();
    
    // Limpiar la lista actual
    _deudasMonitoreadas.clear();
    
    // Agregar las nuevas deudas
    for (final deuda in nuevasDeudas) {
      await agregarDeuda(deuda);
    }

    if (kDebugMode) {
      print('Actualización masiva completada: ${nuevasDeudas.length} deudas');
    }
  }

  /// Obtiene estadísticas de notificaciones
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final notificacionesPendientes = await _servicioNotificaciones.obtenerNotificacionesPendientes();
    
    return {
      'totalDeudas': _deudasMonitoreadas.length,
      'deudasActivas': _deudasMonitoreadas.where((d) => d.activa).length,
      'deudasProximasAVencer': deudasProximasAVencer.length,
      'deudasVencidas': deudasVencidas.length,
      'notificacionesProgramadas': notificacionesPendientes.length,
    };
  }

  /// Limpia todas las notificaciones y reinicia el sistema
  Future<void> limpiarTodo() async {
    await _servicioNotificaciones.cancelarTodasLasNotificaciones();
    _deudasMonitoreadas.clear();
    
    if (kDebugMode) {
      print('Sistema de notificaciones de deudas limpiado');
    }
  }
}
