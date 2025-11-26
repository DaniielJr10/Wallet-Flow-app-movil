/// SECCIÓN DE PREFERENCIAS
/// Muestra y gestiona los ajustes financieros del usuario (Límites, Categoría favorita).
/// Permite la interacción solo si el modo edición está activo.
import 'package:flutter/material.dart';
import 'utils_perfil.dart';

class PreferenciasPerfil extends StatelessWidget {
  final double limiteGastoMensual;
  final String categoriaFavorita;
  final bool modoEdicion;
  final VoidCallback onEditarLimite;
  final VoidCallback onEditarCategoria;

  const PreferenciasPerfil({
    super.key,
    required this.limiteGastoMensual,
    required this.categoriaFavorita,
    required this.modoEdicion,
    required this.onEditarLimite,
    required this.onEditarCategoria,
  });

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
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Preferencias Financieras',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UtilsPerfil.colorTexto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Límite de gasto mensual
          _buildPreferenciaItem(
            titulo: 'Límite de Gasto Mensual',
            valor: UtilsPerfil.formatearMoneda(limiteGastoMensual),
            icono: Icons.account_balance_wallet,
            color: const Color(0xFFEF4444),
            onTap: modoEdicion ? onEditarLimite : null,
          ),

          const SizedBox(height: 16),

          // Categoría favorita (Meta)
          _buildPreferenciaItem(
            titulo: 'Categoría Favorita',
            valor: categoriaFavorita,
            icono: Icons.category,
            color: const Color(0xFF3B82F6),
            onTap: modoEdicion ? onEditarCategoria : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenciaItem({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                color: color,
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
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.edit,
                color: color.withOpacity(0.6),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}