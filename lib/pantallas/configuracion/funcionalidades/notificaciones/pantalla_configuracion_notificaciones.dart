import 'package:flutter/material.dart';
import 'preferencias_notificaciones.dart';
import 'gestor_notificaciones_configuracion.dart';

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

}
