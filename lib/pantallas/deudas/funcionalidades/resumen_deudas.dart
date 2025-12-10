// Tarjeta de estadísticas y totales de deudas (monto total, pagado, pendiente, etc.).
import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_deudas.dart';

class ResumenDeudas extends StatelessWidget {
  final double totalDeudaPendiente;
  final int deudasPorPagar;
  final int deudasPagadas;
  final int totalDeudas;
  final Animation<double> scaleAnimation;

  const ResumenDeudas({
    super.key,
    required this.totalDeudaPendiente,
    required this.deudasPorPagar,
    required this.deudasPagadas,
    required this.totalDeudas,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 12, left: 14, right: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              UtilsDeudas.colorPrincipal,
              UtilsDeudas.colorSecundario,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: UtilsDeudas.colorPrincipal.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Deuda Pendiente',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalDeudas deuda${totalDeudas != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              FormatoNumeros.formatearParaMostrar(totalDeudaPendiente),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.payments,
                    label: 'Deudas por pagar',
                    value: '$deudasPorPagar',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.check_circle_outline,
                    label: 'Deudas pagadas',
                    value: '$deudasPagadas',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Se eliminó la tarjeta de 'Total Deudas'
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}