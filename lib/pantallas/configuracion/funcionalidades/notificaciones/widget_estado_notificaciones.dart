import 'package:flutter/material.dart';
import 'preferencias_notificaciones.dart';
import 'gestor_notificaciones_configuracion.dart';

/// Widget que muestra un resumen del estado de las notificaciones
class EstadoNotificaciones extends StatefulWidget {
  const EstadoNotificaciones({super.key});

  @override
  State<EstadoNotificaciones> createState() => _EstadoNotificacionesState();
}

class _EstadoNotificacionesState extends State<EstadoNotificaciones> {
  Map<String, bool> _preferencias = {};
  Map<String, bool> _estadoSistemas = {};
  bool _cargando = true;
  late GestorNotificacionesConfiguracion _gestor;

  @override
  void initState() {
    super.initState();
    _gestor = GestorNotificacionesConfiguracion();
    _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    try {
      final preferencias = await PreferenciasNotificaciones.obtenerTodasLasPreferencias();
      final estado = await _gestor.verificarEstadoSistemas();
      
      if (mounted) {
        setState(() {
          _preferencias = preferencias;
          _estadoSistemas = estado;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cargando estado de notificaciones...'),
            ],
          ),
        ),
      );
    }

    final notificacionesGeneralesActivas = _preferencias['generales'] ?? true;
    final cantidadActivadas = _preferencias.values.where((activa) => activa).length;
    final totalTipos = _preferencias.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  notificacionesGeneralesActivas ? Icons.notifications_active : Icons.notifications_off,
                  color: notificacionesGeneralesActivas ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Estado de Notificaciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _construirChipEstado(),
              ],
            ),
            const SizedBox(height: 16),
            _construirBarraProgreso(cantidadActivadas, totalTipos),
            const SizedBox(height: 12),
            Text(
              '$cantidadActivadas de $totalTipos tipos de notificaciones activadas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            _construirListaTipos(),
          ],
        ),
      ),
    );
  }

  Widget _construirChipEstado() {
    final notificacionesGeneralesActivas = _preferencias['generales'] ?? true;
    
    return Chip(
      label: Text(
        notificacionesGeneralesActivas ? 'Activas' : 'Desactivadas',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: notificacionesGeneralesActivas ? Colors.green : Colors.red,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _construirBarraProgreso(int activadas, int total) {
    final porcentaje = total > 0 ? activadas / total : 0.0;
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: porcentaje,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            porcentaje > 0.7 ? Colors.green : 
            porcentaje > 0.4 ? Colors.orange : Colors.red,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(porcentaje * 100).toInt()}% configuradas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '$activadas/$total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirListaTipos() {
    final tiposConDescripcion = {
      'generales': {'nombre': 'General', 'icono': Icons.settings, 'color': Colors.purple},
      'ingresos': {'nombre': 'Ingresos', 'icono': Icons.trending_up, 'color': Colors.green},
      'gastos': {'nombre': 'Gastos', 'icono': Icons.trending_down, 'color': Colors.blue},
      'deudas': {'nombre': 'Deudas', 'icono': Icons.warning, 'color': Colors.red},
      'ahorros': {'nombre': 'Ahorros', 'icono': Icons.savings, 'color': Colors.green.shade700},
      'presupuesto': {'nombre': 'Presupuesto', 'icono': Icons.pie_chart, 'color': Colors.indigo},
      'metas': {'nombre': 'Metas', 'icono': Icons.flag, 'color': Colors.orange},
    };

    return Column(
      children: _preferencias.entries.map((entrada) {
        final tipo = entrada.key;
        final activa = entrada.value;
        final info = tiposConDescripcion[tipo]!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                info['icono'] as IconData,
                size: 16,
                color: activa ? info['color'] as Color : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info['nombre'] as String,
                  style: TextStyle(
                    color: activa ? Colors.black87 : Colors.grey,
                    fontWeight: activa ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                activa ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: activa ? Colors.green : Colors.red,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
