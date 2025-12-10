/// ITEM DE HERRAMIENTAS
/// Widget personalizado que muestra la tarjeta de herramientas con 4 iconos
/// de las herramientas disponibles: calculadora, calendario, notas y conversor.
import 'package:flutter/material.dart';

class ItemHerramientas extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ItemHerramientas({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ícono principal y flecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.build_outlined,
                      color: color,
                      size: 16,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 12,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Título
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Fila horizontal con los 4 iconos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Calculadora
                  _buildSmallToolIcon(
                    icon: Icons.calculate_outlined,
                    color: const Color(0xFF6366F1), // Indigo
                  ),
                  // Calendario
                  _buildSmallToolIcon(
                    icon: Icons.calendar_month_outlined,
                    color: const Color(0xFFEF4444), // Red
                  ),
                  // Notas
                  _buildSmallToolIcon(
                    icon: Icons.note_alt_outlined,
                    color: const Color(0xFF10B981), // Emerald
                  ),
                  // Conversor de moneda
                  _buildSmallToolIcon(
                    icon: Icons.currency_exchange_outlined,
                    color: const Color(0xFF8B5CF6), // Purple
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallToolIcon({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 14,
      ),
    );
  }
}