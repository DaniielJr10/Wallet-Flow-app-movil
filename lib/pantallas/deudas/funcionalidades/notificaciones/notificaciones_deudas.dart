/// Exporta todas las funcionalidades del sistema de notificaciones de deudas
/// 
/// Este archivo facilita la importación de todas las clases y widgets
/// relacionados con las notificaciones de deudas en una sola línea.

// Servicios principales
export 'servicio_notificaciones_deudas.dart';
export 'gestor_notificaciones_deudas.dart';

// Inicializador y configuración
export 'inicializador_notificaciones.dart';
export 'configuracion_notificaciones.dart';

// Widgets de interfaz
export 'widgets_notificaciones.dart';

// Importaciones para la clase de conveniencia
import 'servicio_notificaciones_deudas.dart';
import 'gestor_notificaciones_deudas.dart';
import 'inicializador_notificaciones.dart';

/// Clase de conveniencia para acceder a las funcionalidades principales
/// ¡SISTEMA COMPLETAMENTE AUTOMÁTICO! No requiere inicialización manual.
class NotificacionesDeudas {
  /// Servicio principal de notificaciones (auto-inicializable)
  static ServicioNotificacionesDeudas get servicio => ServicioNotificacionesDeudas();
  
  /// Gestor de notificaciones de deudas (auto-inicializable)
  static GestorNotificacionesDeudas get gestor => GestorNotificacionesDeudas();
  
  /// Inicializa todo el sistema de notificaciones (OPCIONAL - se hace automáticamente)
  static Future<void> inicializar() => InicializadorNotificacionesDeudas.inicializar();
  
  /// Verifica si el sistema está inicializado (siempre true porque es automático)
  static bool get estaInicializado => InicializadorNotificacionesDeudas.estaInicializado;
  
  /// Limpia todo el sistema
  static Future<void> limpiarSistema() => InicializadorNotificacionesDeudas.limpiarSistema();
  
  /// Crea una deuda de prueba para testing (se inicializa automáticamente)
  static Future<void> crearDeudaDePrueba() => InicializadorNotificacionesDeudas.crearDeudaDePrueba();
  
  /// Configura notificaciones para una lista de deudas (se inicializa automáticamente)
  static Future<void> configurarParaDeudas(List<Map<String, dynamic>> deudas) =>
      InicializadorNotificacionesDeudas.configurarNotificacionesParaDeudas(deudas);
}
