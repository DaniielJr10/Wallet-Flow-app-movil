/// VISUALIZACIÓN DE RESULTADOS
/// Muestra el monto convertido y una tarjeta informativa con el estado
/// de la tasa de cambio (Online/Offline) y la fecha de actualización.
import 'package:flutter/material.dart';
import 'utils_conversor.dart';

class ResultadoConversor extends StatelessWidget {
  final String result;
  final bool onlineMode;
  final String lastUpdated;
  final String fromCurrency;
  final String toCurrency;
  final Map<String, double> rates;

  const ResultadoConversor({
    super.key,
    required this.result,
    required this.onlineMode,
    required this.lastUpdated,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rates,
  });

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty) return const SizedBox.shrink();

    // Calcular tasa relativa para mostrar
    double tasaRelativa = 0.0;
    if (rates.containsKey(fromCurrency) && rates.containsKey(toCurrency)) {
       tasaRelativa = rates[toCurrency]! / rates[fromCurrency]!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          result,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: UtilsConversor.colorTexto,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                onlineMode ? 'Modo: En línea' : 'Modo: Sin conexión',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tasa $fromCurrency → $toCurrency: ${tasaRelativa.toStringAsFixed(6)}',
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 4),
              if (onlineMode && lastUpdated.isNotEmpty)
                Text(
                  'Actualizado: $lastUpdated',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              if (!onlineMode)
                const Text(
                  'Base de referencia: USD',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}