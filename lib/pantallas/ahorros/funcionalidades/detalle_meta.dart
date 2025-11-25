// 9. Ver detalles completos de una meta de ahorro
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ahorros.dart';

class DetalleMeta extends StatelessWidget {
  final String metaId;
  final Map<String, dynamic> meta;
  final Function() onEditar;
  final Function() onEliminar;

  const DetalleMeta({
    super.key,
    required this.metaId,
    required this.meta,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final categoria = meta['categoria'] ?? 'otros';
    final categoriaInfo = UtilsAhorros.obtenerInfoCategoria(categoria);
    final montoInicial = (meta['montoInicial'] ?? 0.0).toDouble();
    final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
    final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
    final fechaObjetivo = meta['fechaObjetivo'] as DateTime? ?? DateTime.now();
    final fechaCreacion = meta['fechaCreacion'] is Timestamp 
        ? (meta['fechaCreacion'] as Timestamp).toDate() 
        : meta['fechaCreacion'] as DateTime?;
    
    final progreso = montoObjetivo > 0 ? (montoActual / montoObjetivo) : 0.0;
    final diasRestantes = fechaObjetivo.difference(DateTime.now()).inDays;
    final esCompletada = montoActual >= montoObjetivo;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UtilsAhorros.colorPrincipal,
                  UtilsAhorros.colorPrincipal,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta['nombre'] ?? 'Meta sin nombre',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categoriaInfo['nombre'],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetalleItem('Monto actual', FormatoNumeros.formatearParaMostrar(montoActual), Icons.savings_rounded),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Monto objetivo', FormatoNumeros.formatearParaMostrar(montoObjetivo), Icons.flag_rounded),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Monto inicial', FormatoNumeros.formatearParaMostrar(montoInicial), Icons.play_arrow_rounded),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Fecha objetivo', _formatearFecha(fechaObjetivo), Icons.event_rounded),
                  if (fechaCreacion != null) ...[
                    const SizedBox(height: 20),
                    _buildDetalleItem('Fecha de creación', _formatearFecha(fechaCreacion), Icons.calendar_today_rounded),
                  ],
                  const SizedBox(height: 20),
                  _buildDetalleItem('Progreso', '${(progreso * 100).toStringAsFixed(1)}%', Icons.trending_up_rounded),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Días restantes', diasRestantes >= 0 ? '$diasRestantes días' : 'Meta vencida', Icons.hourglass_bottom_rounded),
                  const SizedBox(height: 32),
                  _construirBarraProgreso(progreso, categoriaInfo['color'], esCompletada),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEditar();
                    },
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UtilsAhorros.colorPrincipal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEliminar();
                    },
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: UtilsAhorros.colorPrincipal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              color: UtilsAhorros.colorPrincipal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}