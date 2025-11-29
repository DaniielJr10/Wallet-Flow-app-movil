// Tarjeta de estadísticas y totales de deudas (monto total, pagado, pendiente, etc.).
import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_deudas.dart';

class ResumenDeudas extends StatelessWidget {
  final double totalDeudaPendiente;
  final int deudasVencidas;
  final double pagoMinimoMensual;
  final int totalDeudas;
  final int diasPromedioVencimiento;
  final Animation<double> scaleAnimation;

  const ResumenDeudas({
    super.key,
    required this.totalDeudaPendiente,
    required this.deudasVencidas,
    required this.pagoMinimoMensual,
    required this.totalDeudas,
    required this.diasPromedioVencimiento,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
        padding: const EdgeInsets.all(24),
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
              color: UtilsDeudas.colorPrincipal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalDeudas deuda${totalDeudas != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              FormatoNumeros.formatearParaMostrar(totalDeudaPendiente),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.warning,
                    label: 'Deudas Vencidas',
                    value: '$deudasVencidas',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.payment,
                    label: 'Pago Mínimo',
                    value: '\$${FormatoNumeros.formatearParaMostrar(pagoMinimoMensual)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.list_alt,
                    label: 'Total Deudas',
                    value: '$totalDeudas',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.schedule,
                    label: 'Promedio Vencimiento',
                    value: '$diasPromedioVencimiento días',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}