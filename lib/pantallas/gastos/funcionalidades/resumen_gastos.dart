// ResumenGastos: Tarjeta que muestra el total de gastos y resumen general.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/gastoService/gastos_servicio.dart';
import 'utils_gastos.dart';
import '../../../utilidades/formato_numeros.dart';

class ResumenGastos extends StatelessWidget {
  final GastosServicio gastosServicio;

  const ResumenGastos({super.key, required this.gastosServicio});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: gastosServicio.obtenerGastos(),
      builder: (context, snapshot) {
        double totalGastos = 0;
        int cantidadRegistros = 0;

        if (snapshot.hasData && snapshot.data != null) {
          cantidadRegistros = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalGastos += (data['monto'] as num?)?.toDouble() ?? 0.0;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                UtilsGastos.colorPrincipal,
                UtilsGastos.colorSecundario,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: UtilsGastos.colorPrincipal.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
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
                    'Total de Gastos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$cantidadRegistros registros',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '\$${FormatoNumeros.formatearParaMostrar(totalGastos)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Actualizado hace unos minutos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}