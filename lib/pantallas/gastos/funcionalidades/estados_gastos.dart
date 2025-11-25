// EstadoGastosVacio y EstadoGastosError: Pantallas para mostrar estados vacío y error en gastos.
import 'package:flutter/material.dart';

class EstadoGastosVacio extends StatelessWidget {
  const EstadoGastosVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.payment_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay gastos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primer gasto',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class EstadoGastosError extends StatelessWidget {
  final String error;
  const EstadoGastosError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error al cargar gastos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          Text('Detalle: $error', style: TextStyle(fontSize: 12, color: Colors.red.shade600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class EstadoSinResultadosBusqueda extends StatelessWidget {
  const EstadoSinResultadosBusqueda({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontraron gastos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}