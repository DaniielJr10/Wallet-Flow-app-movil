import 'package:flutter/material.dart';
import 'funcionalidades/notificaciones/notificaciones_deudas.dart';

/// EJEMPLO PRÁCTICO: Cómo usar el sistema automático de notificaciones de deudas
/// 
/// Este archivo muestra cómo integrar el sistema de notificaciones en tu app
/// sin necesidad de inicialización manual. ¡Es completamente automático!

class EjemploNotificacionesAutomaticas extends StatefulWidget {
  const EjemploNotificacionesAutomaticas({super.key});

  @override
  State<EjemploNotificacionesAutomaticas> createState() => 
      _EjemploNotificacionesAutomaticasState();
}

class _EjemploNotificacionesAutomaticasState 
    extends State<EjemploNotificacionesAutomaticas> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones Automáticas'),
        actions: [
          // Contador de alertas en el AppBar (automático)
          ContadorAlertasDeudas(
            onTap: () => _mostrarAlertas(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Widget de alertas en la parte superior (automático)
          AlertasDeudas(
            mostrarSoloUrgentes: true,
            onDeudaTocada: () => _navegarADetalle(),
          ),
          
          // Botones de ejemplo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _agregarDeudaEjemplo,
                  child: const Text('Agregar Deuda de Ejemplo'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _agregarDeudaUrgente,
                  child: const Text('Agregar Deuda Urgente (1 día)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _mostrarEstadisticas,
                  child: const Text('Ver Estadísticas'),
                ),
              ],
            ),
          ),
          
          // Widget de resumen (automático)
          const Expanded(
            child: ResumenNotificaciones(),
          ),
        ],
      ),
    );
  }

  /// Agrega una deuda de ejemplo - ¡Completamente automático!
  Future<void> _agregarDeudaEjemplo() async {
    // NO necesitas inicializar nada, solo úsalo directamente
    final gestor = GestorNotificacionesDeudas();
    
    final deuda = DeudaNotificacion(
      id: DateTime.now().millisecondsSinceEpoch, // ID único
      nombre: 'Pago Tarjeta Crédito',
      monto: 1500.00,
      fechaVencimiento: DateTime.now().add(const Duration(days: 5)),
      activa: true,
    );

    // El sistema se inicializa automáticamente aquí ⚡
    await gestor.agregarDeuda(deuda);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Deuda agregada automáticamente'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Refrescar UI
    }
  }

  /// Agrega una deuda urgente que vence pronto
  Future<void> _agregarDeudaUrgente() async {
    final gestor = GestorNotificacionesDeudas();
    
    final deuda = DeudaNotificacion(
      id: DateTime.now().millisecondsSinceEpoch + 1,
      nombre: 'Deuda URGENTE',
      monto: 800.00,
      fechaVencimiento: DateTime.now().add(const Duration(days: 1)),
      activa: true,
    );

    // ¡Automático! ⚡
    await gestor.agregarDeuda(deuda);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Deuda urgente agregada'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {});
    }
  }

  /// Muestra estadísticas del sistema
  Future<void> _mostrarEstadisticas() async {
    final gestor = GestorNotificacionesDeudas();
    final stats = await gestor.obtenerEstadisticas();
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('📊 Estadísticas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total deudas: ${stats['totalDeudas']}'),
              Text('Deudas activas: ${stats['deudasActivas']}'),
              Text('Próximas a vencer: ${stats['deudasProximasAVencer']}'),
              Text('Deudas vencidas: ${stats['deudasVencidas']}'),
              Text('Notificaciones programadas: ${stats['notificacionesProgramadas']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _mostrarAlertas() {
    // Aquí podrías navegar a una pantalla completa de alertas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mostrando alertas completas')),
    );
  }

  void _navegarADetalle() {
    // Aquí navegarías al detalle de la deuda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a detalle de deuda')),
    );
  }
}

/// Ejemplo de integración en pantalla existente de deudas
class IntegracionEnPantallaDeudas extends StatelessWidget {
  const IntegracionEnPantallaDeudas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Deudas'),
        actions: [
          // Contador automático en el AppBar
          ContadorAlertasDeudas(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Alertas automáticas en la parte superior
          AlertasDeudas(
            mostrarSoloUrgentes: true, // Solo urgentes para no ocupar mucho espacio
            onDeudaTocada: () {
              // Navegar al detalle de la deuda
            },
          ),
          
          // Tu lista de deudas existente
          Expanded(
            child: ListView(
              children: [
                // Aquí van tus tarjetas de deuda existentes
                const ListTile(
                  title: Text('Tarjeta de Crédito'),
                  subtitle: Text('Vence: 15/12/2025'),
                  trailing: Text('\$1,500.00'),
                ),
                // ... más deudas
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarNuevaDeuda(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Ejemplo de cómo agregar una nueva deuda con notificaciones automáticas
  Future<void> _agregarNuevaDeuda(BuildContext context) async {
    // Simulación de datos que vienen de un formulario
    final deudaNueva = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'nombre': 'Nueva Deuda',
      'monto': 1200.00,
      'fechaVencimiento': DateTime.now().add(const Duration(days: 10)),
      'activa': true,
    };

    // ¡AUTOMÁTICO! Solo llamas al método y listo ⚡
    await NotificacionesDeudas.configurarParaDeudas([deudaNueva]);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Deuda agregada con notificaciones automáticas'),
        ),
      );
    }
  }
}

/// Funciones de utilidad para uso rápido
class UtilidadesRapidas {
  /// Agrega múltiples deudas de una vez - TODO AUTOMÁTICO
  static Future<void> cargarDeudasDesdeBaseDatos(List<Map<String, dynamic>> deudasDB) async {
    // ¡Una sola línea y listo! ⚡
    await NotificacionesDeudas.configurarParaDeudas(deudasDB);
    print('✅ ${deudasDB.length} deudas configuradas automáticamente');
  }

  /// Crear deuda de prueba rápida
  static Future<void> crearPrueba() async {
    // ¡Una línea! ⚡
    await NotificacionesDeudas.crearDeudaDePrueba();
    print('✅ Deuda de prueba creada automáticamente');
  }

  /// Limpiar todo el sistema
  static Future<void> limpiar() async {
    await NotificacionesDeudas.limpiarSistema();
    print('🧹 Sistema limpiado');
  }
}
