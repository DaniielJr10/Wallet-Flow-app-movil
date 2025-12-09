// 3. Tarjeta morada de resumen de ahorros
import 'package:flutter/material.dart';
import '../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ahorros.dart';

class ResumenAhorros extends StatelessWidget {
  final AhorrosServicio ahorrosServicio;

  const ResumenAhorros({super.key, required this.ahorrosServicio});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ahorrosServicio.obtenerMetasAhorro(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 120);
        }
        double totalAhorrado = 0;
        int totalMetasCount = snapshot.data!.length;
        int metasCompletadas = 0;
        
        for (var meta in snapshot.data!) {
          final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
          final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
          totalAhorrado += montoActual;
          if (montoActual >= montoObjetivo) {
            metasCompletadas++;
          }
        }
        
        return Container(
          margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: UtilsAhorros.colorPrincipal,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: UtilsAhorros.colorPrincipal.withOpacity(0.3),
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
                    'Total Ahorrado',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalMetasCount ahorro${totalMetasCount != 1 ? 's' : ''}',
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
                FormatoNumeros.formatearParaMostrar(totalAhorrado),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ahorros Completados',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$metasCompletadas de $totalMetasCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}