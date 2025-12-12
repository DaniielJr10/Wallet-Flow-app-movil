import 'package:shared_preferences/shared_preferences.dart';

/// Gestor de preferencias para todos los tipos de notificaciones
class PreferenciasNotificaciones {
  static const String _keyNotificacionesGenerales = 'notificaciones_generales';
  static const String _keyNotificacionesIngresos = 'notificaciones_ingresos';
  static const String _keyNotificacionesGastos = 'notificaciones_gastos';
  static const String _keyNotificacionesDeudas = 'notificaciones_deudas';
  static const String _keyNotificacionesAhorros = 'notificaciones_ahorros';
  static const String _keyNotificacionesPresupuesto = 'notificaciones_presupuesto';
  static const String _keyNotificacionesMetas = 'notificaciones_metas';

  /// Obtiene todas las preferencias de notificaciones
  static Future<Map<String, bool>> obtenerTodasLasPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'generales': prefs.getBool(_keyNotificacionesGenerales) ?? true,
      'ingresos': prefs.getBool(_keyNotificacionesIngresos) ?? true,
      'gastos': prefs.getBool(_keyNotificacionesGastos) ?? true,
      'deudas': prefs.getBool(_keyNotificacionesDeudas) ?? true,
      'ahorros': prefs.getBool(_keyNotificacionesAhorros) ?? true,
      'presupuesto': prefs.getBool(_keyNotificacionesPresupuesto) ?? true,
      'metas': prefs.getBool(_keyNotificacionesMetas) ?? true,
    };
  }

  /// Guarda una preferencia específica
  static Future<void> guardarPreferencia(String tipo, bool activa) async {
    final prefs = await SharedPreferences.getInstance();
    
    String key;
    switch (tipo) {
      case 'generales':
        key = _keyNotificacionesGenerales;
        break;
      case 'ingresos':
        key = _keyNotificacionesIngresos;
        break;
      case 'gastos':
        key = _keyNotificacionesGastos;
        break;
      case 'deudas':
        key = _keyNotificacionesDeudas;
        break;
      case 'ahorros':
        key = _keyNotificacionesAhorros;
        break;
      case 'presupuesto':
        key = _keyNotificacionesPresupuesto;
        break;
      case 'metas':
        key = _keyNotificacionesMetas;
        break;
      default:
        return;
    }
    
    await prefs.setBool(key, activa);
  }

  /// Obtiene una preferencia específica
  static Future<bool> obtenerPreferencia(String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    
    String key;
    switch (tipo) {
      case 'generales':
        key = _keyNotificacionesGenerales;
        break;
      case 'ingresos':
        key = _keyNotificacionesIngresos;
        break;
      case 'gastos':
        key = _keyNotificacionesGastos;
        break;
      case 'deudas':
        key = _keyNotificacionesDeudas;
        break;
      case 'ahorros':
        key = _keyNotificacionesAhorros;
        break;
      case 'presupuesto':
        key = _keyNotificacionesPresupuesto;
        break;
      case 'metas':
        key = _keyNotificacionesMetas;
        break;
      default:
        return true;
    }
    
    return prefs.getBool(key) ?? true;
  }

  /// Activa o desactiva todas las notificaciones
  static Future<void> configurarTodasLasNotificaciones(bool activas) async {
    final tipos = ['generales', 'ingresos', 'gastos', 'deudas', 'ahorros', 'presupuesto', 'metas'];
    
    for (String tipo in tipos) {
      await guardarPreferencia(tipo, activas);
    }
  }

  /// Verifica si las notificaciones están habilitadas globalmente
  static Future<bool> notificacionesHabilitadasGlobalmente() async {
    return await obtenerPreferencia('generales');
  }

  /// Verifica si hay al menos una notificación específica activa
  /// Retorna true si ingresos, gastos, ahorros o deudas está activa
  static Future<bool> hayNotificacionEspecificaActiva() async {
    final prefs = await SharedPreferences.getInstance();
    
    final ingresos = prefs.getBool(_keyNotificacionesIngresos) ?? true;
    final gastos = prefs.getBool(_keyNotificacionesGastos) ?? true;
    final ahorros = prefs.getBool(_keyNotificacionesAhorros) ?? true;
    final deudas = prefs.getBool(_keyNotificacionesDeudas) ?? true;
    
    return ingresos || gastos || ahorros || deudas;
  }
}
