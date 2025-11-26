/// PANTALLAS DE ESTADO
/// Widgets reutilizables para informar al usuario cuando no hay datos
/// (EstadoVacio) o cuando ocurre un error de conexión (EstadoError).
import 'package:flutter/material.dart';
import 'utils_ingresos.dart';

class EstadoIngresosVacio extends StatelessWidget {
  final String mensaje;
  const EstadoIngresosVacio({super.key, this.mensaje = 'No hay ingresos registrados'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.attach_money_rounded,
              size: 64,
              color: Colors.green.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          if (mensaje == 'No hay ingresos registrados')
            const Text(
              'Comienza registrando tu primer ingreso',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class EstadoIngresosError extends StatelessWidget {
  const EstadoIngresosError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar ingresos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}