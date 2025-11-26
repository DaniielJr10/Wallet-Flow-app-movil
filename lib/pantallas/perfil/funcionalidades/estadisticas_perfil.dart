/// SECCIÓN DE ESTADÍSTICAS
/// Visualiza los datos numéricos del usuario (transacciones, ahorros, días activo)
/// en un Grid de tarjetas personalizadas.
import 'package:flutter/material.dart';
import 'utils_perfil.dart';

class EstadisticasPerfil extends StatelessWidget {
  final Map<String, dynamic> estadisticas;

  const EstadisticasPerfil({super.key, required this.estadisticas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Título de la sección
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estadísticas de Uso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UtilsPerfil.colorTexto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Grid de estadísticas
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildEstadisticaCard(
                'Transacciones',
                '${estadisticas['transaccionesTotales'] ?? 0}',
                Icons.receipt_long,
                const Color(0xFF10B981),
              ),
              _buildEstadisticaCard(
                'Gasto Promedio',
                UtilsPerfil.formatearMoneda(estadisticas['gastoPromedio']?.toDouble() ?? 0),
                Icons.trending_down,
                const Color(0xFFEF4444),
              ),
              _buildEstadisticaCard(
                'Ahorro Total',
                UtilsPerfil.formatearMoneda(estadisticas['ahorroTotal']?.toDouble() ?? 0),
                Icons.savings,
                const Color(0xFF3B82F6),
              ),
              _buildEstadisticaCard(
                'Días Activo',
                '${estadisticas['diasActivo'] ?? 0}',
                Icons.calendar_month,
                const Color(0xFFF59E0B),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Categoría más usada (Tarjeta grande inferior)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF7C3AED),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categoría Favorita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        estadisticas['categoriaMasUsada'] ?? 'General',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaCard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}