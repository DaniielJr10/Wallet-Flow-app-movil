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
              color: UtilsDeudas.colorPrincipal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Total deuda pendiente
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Text(
                      'Total Deuda Pendiente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${FormatoNumeros.formatearParaMostrar(totalDeudaPendiente)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Estadísticas en grid
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Deudas Vencidas',
                    '$deudasVencidas',
                    Icons.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Pago Mínimo',
                    '\$${FormatoNumeros.formatearParaMostrar(pagoMinimoMensual)}',
                    Icons.payment,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Total Deudas',
                    '$totalDeudas',
                    Icons.list_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Promedio Vencimiento',
                    '$diasPromedioVencimiento días',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaResumen(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}