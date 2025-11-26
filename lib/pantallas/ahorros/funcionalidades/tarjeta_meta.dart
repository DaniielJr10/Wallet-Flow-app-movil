// 7. Diseño de cada meta y sus barras de progreso
import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ahorros.dart';

class TarjetaMeta extends StatelessWidget {
  final String id;
  final Map<String, dynamic> meta;
  final int index;
  final VoidCallback onTap;
  final Function(String id, Map<String, dynamic> meta) onAccionSeleccionada;

  const TarjetaMeta({
    super.key,
    required this.id,
    required this.meta,
    required this.index,
    required this.onTap,
    required this.onAccionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    final categoria = meta['categoria'] ?? 'otros';
    final categoriaInfo = UtilsAhorros.obtenerInfoCategoria(categoria);

    final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
    final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
    final progreso = montoObjetivo > 0 ? (montoActual / montoObjetivo) : 0.0;
    final fechaObjetivo = meta['fechaObjetivo'] as DateTime? ?? DateTime.now();
    final diasRestantes = fechaObjetivo.difference(DateTime.now()).inDays;
    final esCompletada = montoActual >= montoObjetivo;

    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        top: index == 0 ? 8 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: esCompletada
                  ? Border.all(color: UtilsAhorros.colorPrincipal, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirCabeceraTarjeta(categoriaInfo, meta, esCompletada),
                const SizedBox(height: 16),
                _construirProgresoDinero(montoActual, montoObjetivo, diasRestantes),
                const SizedBox(height: 16),
                _construirBarraProgreso(progreso, categoriaInfo['color'], esCompletada),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirCabeceraTarjeta(Map<String, dynamic> categoriaInfo, Map<String, dynamic> meta, bool esCompletada) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoriaInfo['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            categoriaInfo['icono'],
            color: categoriaInfo['color'],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meta['nombre'] ?? 'Meta sin nombre',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D29),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoriaInfo['nombre'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _construirAccionesMeta(esCompletada),
      ],
    );
  }

  Widget _construirAccionesMeta(bool esCompletada) {
    if (esCompletada) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: UtilsAhorros.colorPrincipal,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'COMPLETADA',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _construirProgresoDinero(double montoActual, double montoObjetivo, int diasRestantes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progreso actual',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Actual: ${FormatoNumeros.formatearParaMostrar(montoActual)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D29),
              ),
            ),
            Text(
              'Objetivo: ${FormatoNumeros.formatearParaMostrar(montoObjetivo)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D29),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              diasRestantes >= 0 ? 'Días restantes' : 'Días de retraso',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${diasRestantes.abs()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: diasRestantes >= 0 ? UtilsAhorros.colorPrincipal : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirBarraProgreso(double progreso, Color color, bool esCompletada) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${(progreso * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: UtilsAhorros.colorPrincipal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              esCompletada ? UtilsAhorros.colorPrincipal : color,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}