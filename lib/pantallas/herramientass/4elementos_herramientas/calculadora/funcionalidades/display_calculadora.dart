/// PANTALLA DE RESULTADOS
/// Muestra la operación actual con scroll horizontal y el resultado
/// final en tamaño grande, ajustándose para evitar desbordamientos.
import 'package:flutter/material.dart';
import 'utils_calculadora.dart';

class DisplayCalculadora extends StatelessWidget {
  final String expression;
  final String result;

  const DisplayCalculadora({
    super.key,
    required this.expression,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: UtilsCalculadora.colorDisplayBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UtilsCalculadora.colorDisplayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expresión (Scroll horizontal)
          SizedBox(
            height: 28,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                expression.isEmpty ? '0' : expression,
                style: const TextStyle(
                  fontSize: 18,
                  color: UtilsCalculadora.colorTextoOscuro,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Resultado (Auto-escalable)
          SizedBox(
            height: 54,
            child: Row(
              children: [
                const Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        result,
                        key: ValueKey(result),
                        style: const TextStyle(
                          fontSize: 48,
                          color: UtilsCalculadora.colorPrincipal,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}