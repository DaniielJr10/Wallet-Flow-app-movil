import 'package:flutter/material.dart';
import '../../../../utilidades/formato_numeros.dart';
import '../../../../firebase/servicios/ingresos_servicio.dart';

class ResumenIngresos extends StatelessWidget {
  ResumenIngresos({super.key});

  final IngresosServicio _ingresosServicio = IngresosServicio();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ingresosServicio.obtenerIngresos(),
      builder: (context, snapshot) {
        final ingresos = snapshot.data ?? [];
        final totalIngresos = ingresos.fold<double>(
          0.0,
          (sum, ingreso) => sum + (ingreso['monto'] as num).toDouble(),
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2ecc71),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ecc71).withOpacity(0.3),
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
                    'Total de Ingresos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ingresos.length} registros',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                FormatoNumeros.formatearParaMostrar(totalIngresos),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Actualizado hace unos minutos',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        );
      },
    );
  }
}