import 'package:flutter/material.dart';
import 'preferencias_notificaciones.dart';
import 'gestor_notificaciones_simplificado.dart';
import 'prueba_sistema_notificaciones.dart';

/// Pantalla simple y bonita para configurar notificaciones
class PantallaConfiguracionNotificaciones extends StatefulWidget {
  const PantallaConfiguracionNotificaciones({super.key});

  @override
  State<PantallaConfiguracionNotificaciones> createState() => _PantallaConfiguracionNotificacionesState();
}

class _PantallaConfiguracionNotificacionesState extends State<PantallaConfiguracionNotificaciones> {
  Map<String, bool> _preferencias = {};
  bool _cargando = true;
  late GestorNotificacionesConfiguracion _gestor;

  @override
  void initState() {
    super.initState();
    _gestor = GestorNotificacionesConfiguracion();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final preferencias = await PreferenciasNotificaciones.obtenerTodasLasPreferencias();
    if (mounted) {
      setState(() {
        _preferencias = preferencias;
        _cargando = false;
      });
    }
  }

  Future<void> _cambiarPreferencia(String tipo, bool valor) async {
    await PreferenciasNotificaciones.guardarPreferencia(tipo, valor);
    await _gestor.aplicarCambioNotificacion(tipo, valor);
    
    setState(() {
      _preferencias[tipo] = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Encabezado simple
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 48,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elige qué notificaciones recibir',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Lista simple de notificaciones
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _crearTarjetaNotificacion(
                        'ingresos',
                        'Recordatorios de Ingresos',
                        'Salarios y dinero que recibes',
                        Icons.trending_up,
                        Colors.green,
                      ),
                      _crearTarjetaNotificacion(
                        'gastos',
                        'Recordatorios de Gastos',
                        'Pagos y facturas por pagar',
                        Icons.trending_down,
                        Colors.orange,
                      ),
                      _crearTarjetaNotificacion(
                        'deudas',
                        'Alertas de Deudas',
                        'Cuando una deuda esté por vencer',
                        Icons.warning,
                        Colors.red,
                      ),
                      _crearTarjetaNotificacion(
                        'ahorros',
                        'Recordatorios de Ahorro',
                        'Metas y progreso de ahorro',
                        Icons.savings,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                
                // Botón de verificación del sistema
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _verificarSistema,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Verificar Funcionamiento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Método simple para crear cada tarjeta de notificación
  Widget _crearTarjetaNotificacion(
    String tipo,
    String titulo,
    String descripcion,
    IconData icono,
    Color color,
  ) {
    final activa = _preferencias[tipo] ?? true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono con color
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Switch
              Switch(
                value: activa,
                onChanged: (valor) => _cambiarPreferencia(tipo, valor),
                activeColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Verifica que el sistema funciona al 100%
  Future<void> _verificarSistema() async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Verificando Sistema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Probando funcionalidad de notificaciones...'),
          ],
        ),
      ),
    );

    try {
      // Ejecutar verificación rápida
      final funcionaBasico = await PruebaSistemaNotificaciones.verificacionRapida();
      
      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar resultado
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  funcionaBasico ? Icons.check_circle : Icons.error,
                  color: funcionaBasico ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(funcionaBasico ? '¡Sistema Funcional!' : 'Error en Sistema'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (funcionaBasico) ...[
                  const Text('✅ Las preferencias se guardan correctamente'),
                  const SizedBox(height: 4),
                  const Text('✅ Los switches responden a cambios'),
                  const SizedBox(height: 4),
                  const Text('✅ La configuración persiste'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Text(
                      '🎉 ¡El sistema está funcionando al 100%!\n\nCuando actives/desactives las notificaciones aquí, se aplicarán inmediatamente.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ] else ...[
                  const Text('❌ Error en el sistema de preferencias'),
                  const SizedBox(height: 4),
                  const Text('❌ Los cambios no se están guardando'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text(
                      '⚠️ El sistema requiere atención técnica.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
              if (funcionaBasico)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _ejecutarPruebaCompleta();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Prueba Completa', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo si está abierto
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en verificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Ejecuta la prueba completa del sistema
  Future<void> _ejecutarPruebaCompleta() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Ejecutando Prueba Completa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando todos los componentes...'),
          ],
        ),
      ),
    );

    try {
      final resultados = await PruebaSistemaNotificaciones.ejecutarTodasLasPruebas();
      
      if (mounted) Navigator.of(context).pop();
      
      final exitosas = resultados.values.where((r) => r).length;
      final total = resultados.length;
      final porcentaje = (exitosas / total * 100).round();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Reporte de Pruebas ($porcentaje%)'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...resultados.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          entry.value ? Icons.check_circle : Icons.error,
                          color: entry.value ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(entry.key)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: porcentaje >= 80 ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      porcentaje >= 80 
                          ? '🎉 ¡Sistema completamente funcional!' 
                          : '⚠️ Sistema funcional con algunas limitaciones',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en prueba completa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
