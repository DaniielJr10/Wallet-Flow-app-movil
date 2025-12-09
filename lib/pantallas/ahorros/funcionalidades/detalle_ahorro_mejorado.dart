/// DETALLE DE AHORRO MEJORADO
/// Modal que muestra los detalles completos de un ahorro siguiendo el mismo diseño que ingresos/gastos.
/// Incluye botones de acción y información organizada profesionalmente.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ahorros.dart';

class DetalleAhorroMejorado extends StatelessWidget {
  final String ahorroId;
  final Map<String, dynamic> ahorro;
  final Function() onEditar;
  final Function() onEliminar;
  final Function() onAgregarDinero;

  const DetalleAhorroMejorado({
    super.key,
    required this.ahorroId,
    required this.ahorro,
    required this.onEditar,
    required this.onEliminar,
    required this.onAgregarDinero,
  });

  @override
  Widget build(BuildContext context) {
    final categoria = ahorro['categoria'] ?? 'otros';
    final categoriaInfo = UtilsAhorros.obtenerInfoCategoria(categoria);
    final montoInicial = (ahorro['montoInicial'] ?? 0.0).toDouble();
    final montoActual = (ahorro['montoActual'] ?? 0.0).toDouble();
    final montoObjetivo = (ahorro['montoObjetivo'] ?? 0.0).toDouble();
    final fechaObjetivo = ahorro['fechaObjetivo'] is DateTime 
        ? ahorro['fechaObjetivo'] as DateTime
        : (ahorro['fechaObjetivo'] is Timestamp 
            ? (ahorro['fechaObjetivo'] as Timestamp).toDate() 
            : DateTime.now());
    final fechaCreacion = ahorro['fechaCreacion'] is Timestamp 
        ? (ahorro['fechaCreacion'] as Timestamp).toDate() 
        : ahorro['fechaCreacion'] as DateTime?;
    
    final progreso = montoObjetivo > 0 ? (montoActual / montoObjetivo).clamp(0.0, 1.0) : 0.0;
    final diasRestantes = fechaObjetivo.difference(DateTime.now()).inDays;
    final esCompletada = montoActual >= montoObjetivo;
    final faltaPorAhorrar = (montoObjetivo - montoActual).clamp(0.0, double.infinity);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Header con gradiente
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UtilsAhorros.colorPrincipal,
                  Color(0xFF9F7AFA),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      categoriaInfo['icono'],
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ahorro['nombre'] ?? 'Ahorro sin nombre',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            categoriaInfo['nombre'],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Monto principal y progreso en el header
                Column(
                  children: [
                    Text(
                      FormatoNumeros.formatearParaMostrar(montoActual),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'de ${FormatoNumeros.formatearParaMostrar(montoObjetivo)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Barra de progreso en el header
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progreso,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progreso * 100).toStringAsFixed(1)}% completado',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        if (esCompletada)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '¡Completado!',
                              style: TextStyle(
                                color: UtilsAhorros.colorPrincipal,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Contenido con detalles
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas principales
                  Row(
                    children: [
                      Expanded(
                        child: _buildEstadisticaCard(
                          'Monto inicial',
                          FormatoNumeros.formatearParaMostrar(montoInicial),
                          Icons.play_arrow_rounded,
                          Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEstadisticaCard(
                          'Faltan por ahorrar',
                          FormatoNumeros.formatearParaMostrar(faltaPorAhorrar),
                          Icons.trending_up_rounded,
                          Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Información adicional
                  _buildSeccionInfo([
                    _InfoItem('Fecha objetivo', _formatearFecha(fechaObjetivo), Icons.event_rounded),
                    _InfoItem(
                      'Estado',
                      diasRestantes >= 0 
                          ? (diasRestantes == 0 ? 'Vence hoy' : '$diasRestantes días restantes')
                          : 'Meta vencida',
                      diasRestantes >= 0 ? Icons.schedule_rounded : Icons.warning_rounded,
                    ),
                    if (fechaCreacion != null)
                      _InfoItem('Fecha de creación', _formatearFecha(fechaCreacion), Icons.calendar_today_rounded),
                  ]),
                ],
              ),
            ),
          ),
          // Botones de acción
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Botón principal - Agregar dinero
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onAgregarDinero();
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Agregar Dinero'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UtilsAhorros.colorPrincipal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botones secundarios
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onEditar();
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: UtilsAhorros.colorPrincipal, width: 1.5),
                          foregroundColor: UtilsAhorros.colorPrincipal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onEliminar();
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red.shade400, width: 1.5),
                          foregroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildEstadisticaCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionInfo(List<_InfoItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información adicional',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0) const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: UtilsAhorros.colorPrincipal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icono,
                        color: UtilsAhorros.colorPrincipal,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.titulo,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.valor,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

class _InfoItem {
  final String titulo;
  final String valor;
  final IconData icono;

  _InfoItem(this.titulo, this.valor, this.icono);
}
