import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'gestor_notificaciones_ahorros.dart';

/// Widgets de interfaz para mostrar estado y controlar notificaciones de ahorros
class WidgetsNotificacionesAhorros {
  
  /// Widget que muestra el estado actual de las notificaciones de ahorros
  static Widget indicadorEstado({
    required BuildContext context,
    bool mostrarTexto = true,
  }) {
    return FutureBuilder<bool>(
      future: GestorNotificacionesAhorros.instance.estanActivasLasNotificaciones(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              if (mostrarTexto) ...[
                const SizedBox(width: 8),
                const Text('Verificando...', style: TextStyle(fontSize: 12)),
              ],
            ],
          );
        }
        
        final activo = snapshot.data ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activo ? Icons.notifications_active : Icons.notifications_off,
              color: activo ? Colors.green : Colors.grey,
              size: 18,
            ),
            if (mostrarTexto) ...[
              const SizedBox(width: 4),
              Text(
                activo ? 'Activas' : 'Inactivas',
                style: TextStyle(
                  color: activo ? Colors.green : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  /// Switch para activar/desactivar notificaciones de ahorros
  static Widget switchNotificaciones({
    required BuildContext context,
    required ValueChanged<bool> onChanged,
    String? titulo,
  }) {
    return FutureBuilder<bool>(
      future: GestorNotificacionesAhorros.instance.estanActivasLasNotificaciones(),
      builder: (context, snapshot) {
        final activo = snapshot.data ?? true;
        
        if (titulo != null) {
          return SwitchListTile(
            title: Text(titulo),
            subtitle: Text(activo 
                ? 'Recibirás recordatorios de tus metas de ahorro'
                : 'No recibirás notificaciones de ahorros'),
            value: activo,
            onChanged: snapshot.connectionState == ConnectionState.waiting 
                ? null 
                : (valor) async {
                    await GestorNotificacionesAhorros.instance.configurarSistema(valor);
                    onChanged(valor);
                  },
          );
        } else {
          return Switch(
            value: activo,
            onChanged: snapshot.connectionState == ConnectionState.waiting 
                ? null 
                : (valor) async {
                    await GestorNotificacionesAhorros.instance.configurarSistema(valor);
                    onChanged(valor);
                  },
          );
        }
      },
    );
  }
  
  /// Tarjeta con resumen de estadísticas de notificaciones
  static Widget tarjetaEstadisticas({
    required BuildContext context,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: GestorNotificacionesAhorros.instance.obtenerEstadisticas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final estadisticas = snapshot.data ?? {};
        final activas = estadisticas['notificaciones_activas'] ?? false;
        final programadas = estadisticas['notificaciones_programadas'] ?? 0;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.savings,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Notificaciones de Ahorros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _construirEstadistica(
                      icono: Icons.notifications_active,
                      valor: activas ? 'Activas' : 'Inactivas',
                      color: activas ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    _construirEstadistica(
                      icono: Icons.schedule,
                      valor: '$programadas programadas',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Widget auxiliar para construir estadísticas
  static Widget _construirEstadistica({
    required IconData icono,
    required String valor,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icono, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          valor,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  /// Botón para probar las notificaciones de ahorros
  static Widget botonPrueba({
    required BuildContext context,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _ejecutarPrueba(context),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Probar Notificaciones'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
  
  /// Ejecuta una prueba del sistema de notificaciones
  static Future<void> _ejecutarPrueba(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Probando Sistema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando notificaciones de ahorros...'),
            ],
          ),
        ),
      );
      
      // Ejecutar prueba
      final resultado = await GestorNotificacionesAhorros.instance.ejecutarPrueba();
      
      // Cerrar diálogo de carga
      if (context.mounted) Navigator.of(context).pop();
      
      // Mostrar resultado
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  resultado ? Icons.check_circle : Icons.error,
                  color: resultado ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(resultado ? '¡Prueba Exitosa!' : 'Error en Prueba'),
              ],
            ),
            content: Text(
              resultado 
                  ? 'El sistema de notificaciones de ahorros está funcionando correctamente. '
                    'Recibirás recordatorios cuando tengas metas activas.'
                  : 'Hubo un problema con el sistema de notificaciones. '
                    'Revisa los permisos de la aplicación.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo si está abierto
      if (context.mounted) Navigator.of(context).pop();
      
      // Mostrar error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ejecutando prueba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Widget de configuración avanzada de notificaciones
  static Widget configuracionAvanzada({
    required BuildContext context,
  }) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.settings),
        title: const Text('Configuración Avanzada'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                switchNotificaciones(
                  context: context,
                  onChanged: (valor) {
                    final mensaje = valor 
                        ? 'Notificaciones de ahorros activadas'
                        : 'Notificaciones de ahorros desactivadas';
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(mensaje),
                        backgroundColor: valor ? Colors.green : Colors.orange,
                      ),
                    );
                  },
                  titulo: 'Recordatorios de Metas',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: botonPrueba(context: context)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _limpiarNotificaciones(context),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Limpiar Todo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Limpia todas las notificaciones programadas
  static Future<void> _limpiarNotificaciones(BuildContext context) async {
    try {
      final confirmacion = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Limpieza'),
          content: const Text(
            '¿Estás seguro de que quieres cancelar todas las '
            'notificaciones de ahorros programadas?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Limpiar Todo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (confirmacion == true) {
        await GestorNotificacionesAhorros.instance.limpiarSistema();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todas las notificaciones de ahorros han sido canceladas'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error limpiando notificaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Widget simple para mostrar en la pantalla principal de ahorros
  static Widget indicadorPantallaPrincipal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: indicadorEstado(
        context: null as dynamic, // Se maneja internamente
        mostrarTexto: true,
      ),
    );
  }
}
