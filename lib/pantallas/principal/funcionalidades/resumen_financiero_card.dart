/// TARJETA DE RESUMEN
/// Widget que carga los datos financieros (ingresos, gastos, deudas, etc.)
/// usando `PrincipalServicio` y los muestra en un grid usando `ItemResumen`.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/PrincipalService/principal_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'item_resumen.dart';
import 'item_herramientas.dart';

class ResumenFinancieroCard extends StatelessWidget {
  final PrincipalServicio servicio;
  final Function(int) onNavigate;

  const ResumenFinancieroCard({
    super.key,
    required this.servicio,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: servicio.obtenerResumenFinanciero(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (snapshot.hasError) {
          return _buildError();
        }

        final data = snapshot.data ?? {};
        final totalCuentas = data['totalCuentas'] ?? 0.0;
        final ingresosDelMes = data['ingresosDelMes'] ?? 0.0;
        final gastosDelMes = data['gastosDelMes'] ?? 0.0;
        final totalAhorros = data['totalAhorros'] ?? 0.0;
        final totalDeudas = data['totalDeudas'] ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Fila 1: Ingresos y Gastos
              Row(
                children: [
                  Expanded(
                    child: ItemResumen(
                      title: 'Ingresos',
                      amount: FormatoNumeros.formatearParaMostrar(ingresosDelMes),
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF2ecc71),
                      onTap: () => onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ItemResumen(
                      title: 'Gastos',
                      amount: FormatoNumeros.formatearParaMostrar(gastosDelMes),
                      icon: Icons.trending_down_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: () => onNavigate(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Fila 2: Cuentas y Deudas
              Row(
                children: [
                  Expanded(
                    child: ItemResumen(
                      title: 'Cuentas',
                      amount: FormatoNumeros.formatearParaMostrar(totalCuentas),
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFF2563EB),
                      onTap: () => onNavigate(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ItemResumen(
                      title: 'Deudas',
                      amount: FormatoNumeros.formatearParaMostrar(totalDeudas),
                      icon: Icons.credit_card_rounded,
                      color: Colors.orange.shade600,
                      onTap: () => onNavigate(5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Fila 3: Ahorros y Herramientas
              Row(
                children: [
                  Expanded(
                    child: ItemResumen(
                      title: 'Ahorros',
                      amount: FormatoNumeros.formatearParaMostrar(totalAhorros),
                      icon: Icons.savings_rounded,
                      color: const Color(0xFF8570FA),
                      onTap: () => onNavigate(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ItemHerramientas(
                      title: 'Herramientas',
                      color: Colors.indigo.shade600,
                      onTap: () => onNavigate(7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Error al cargar datos', style: TextStyle(color: Colors.red)),
      ),
    );
  }
}