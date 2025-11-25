// Widgets para mostrar estados de carga (loading) y vacíos en la sección de deudas.
import 'package:flutter/material.dart';
import 'utils_deudas.dart';

class EstadoCargandoDeudas extends StatelessWidget {
  const EstadoCargandoDeudas({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(UtilsDeudas.colorPrincipal),
          ),
          SizedBox(height: 24),
          Text(
            'Cargando tus deudas...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class EstadoListaVacia extends StatelessWidget {
  final String filtroSeleccionado;

  const EstadoListaVacia({super.key, required this.filtroSeleccionado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            filtroSeleccionado == 'Todas' 
                ? '¡Sin deudas registradas!'
                : 'No hay deudas en esta categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            filtroSeleccionado == 'Todas'
                ? 'Mantén un control financiero saludable'
                : 'Intenta con otro filtro',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}