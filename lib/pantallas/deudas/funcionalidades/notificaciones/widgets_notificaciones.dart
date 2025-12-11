import 'package:flutter/material.dart';
import 'gestor_notificaciones_deudas.dart';

/// Widget que muestra las alertas de deudas próximas a vencer
class AlertasDeudas extends StatefulWidget {
  final bool mostrarSoloUrgentes;
  final VoidCallback? onDeudaTocada;

  const AlertasDeudas({
    super.key,
    this.mostrarSoloUrgentes = false,
    this.onDeudaTocada,
  });

  @override
  State<AlertasDeudas> createState() => _AlertasDeudasState();
}

class _AlertasDeudasState extends State<AlertasDeudas> {
  final GestorNotificacionesDeudas _gestor = GestorNotificacionesDeudas();

  @override
  Widget build(BuildContext context) {
    final deudasProximas = _gestor.deudasProximasAVencer;
    final deudasVencidas = _gestor.deudasVencidas;

    if (widget.mostrarSoloUrgentes) {
      final deudasUrgentes = deudasProximas.where((d) => d.diasRestantes <= 1).toList();
      if (deudasUrgentes.isEmpty && deudasVencidas.isEmpty) {
        return const SizedBox.shrink();
      }
    } else {
      if (deudasProximas.isEmpty && deudasVencidas.isEmpty) {
        return const SizedBox.shrink();
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alertas de Deudas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Deudas vencidas
            if (deudasVencidas.isNotEmpty) ...[
              _construirSeccionDeudas(
                context,
                'Deudas Vencidas',
                deudasVencidas,
                Colors.red.shade800,
                Icons.error,
              ),
              if (deudasProximas.isNotEmpty) const SizedBox(height: 16),
            ],
            
            // Deudas próximas a vencer
            if (deudasProximas.isNotEmpty) ...[
              Builder(
                builder: (context) {
                  final deudasAMostrar = widget.mostrarSoloUrgentes 
                      ? deudasProximas.where((d) => d.diasRestantes <= 1).toList()
                      : deudasProximas;
                  
                  if (deudasAMostrar.isNotEmpty) {
                    return _construirSeccionDeudas(
                      context,
                      'Próximas a Vencer',
                      deudasAMostrar,
                      Colors.orange.shade700,
                      Icons.schedule,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirSeccionDeudas(
    BuildContext context,
    String titulo,
    List<DeudaNotificacion> deudas,
    Color color,
    IconData icono,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...deudas.map((deuda) => _construirTarjetaDeuda(context, deuda)),
      ],
    );
  }

  Widget _construirTarjetaDeuda(BuildContext context, DeudaNotificacion deuda) {
    final esVencida = deuda.vencida;
    final color = esVencida ? Colors.red : Colors.orange;
    
    String textoTiempo;
    if (esVencida) {
      final diasVencida = deuda.diasRestantes.abs();
      textoTiempo = diasVencida == 1 ? 'Vencida ayer' : 'Vencida hace $diasVencida días';
    } else if (deuda.diasRestantes == 0) {
      textoTiempo = 'Vence HOY';
    } else if (deuda.diasRestantes == 1) {
      textoTiempo = 'Vence mañana';
    } else {
      textoTiempo = 'Vence en ${deuda.diasRestantes} días';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          deuda.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monto: \$${deuda.monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              textoTiempo,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Icon(
          esVencida ? Icons.error : Icons.warning,
          color: color,
        ),
        onTap: widget.onDeudaTocada,
      ),
    );
  }
}

/// Widget compacto para mostrar solo el contador de alertas
class ContadorAlertasDeudas extends StatefulWidget {
  final VoidCallback? onTap;

  const ContadorAlertasDeudas({super.key, this.onTap});

  @override
  State<ContadorAlertasDeudas> createState() => _ContadorAlertasDeudasState();
}

class _ContadorAlertasDeudasState extends State<ContadorAlertasDeudas> {
  final GestorNotificacionesDeudas _gestor = GestorNotificacionesDeudas();

  @override
  Widget build(BuildContext context) {
    final totalAlertas = _gestor.deudasProximasAVencer.length + _gestor.deudasVencidas.length;
    
    if (totalAlertas == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$totalAlertas',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar un resumen de las notificaciones programadas
class ResumenNotificaciones extends StatefulWidget {
  const ResumenNotificaciones({super.key});

  @override
  State<ResumenNotificaciones> createState() => _ResumenNotificacionesState();
}

class _ResumenNotificacionesState extends State<ResumenNotificaciones> {
  final GestorNotificacionesDeudas _gestor = GestorNotificacionesDeudas();
  Map<String, dynamic>? _estadisticas;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final stats = await _gestor.obtenerEstadisticas();
    if (mounted) {
      setState(() {
        _estadisticas = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_estadisticas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de Notificaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _construirFilaEstadistica('Total de deudas', _estadisticas!['totalDeudas']),
            _construirFilaEstadistica('Deudas activas', _estadisticas!['deudasActivas']),
            _construirFilaEstadistica('Próximas a vencer', _estadisticas!['deudasProximasAVencer']),
            _construirFilaEstadistica('Deudas vencidas', _estadisticas!['deudasVencidas']),
            _construirFilaEstadistica('Notificaciones programadas', _estadisticas!['notificacionesProgramadas']),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarEstadisticas,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFilaEstadistica(String etiqueta, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta),
          Text(
            valor.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
