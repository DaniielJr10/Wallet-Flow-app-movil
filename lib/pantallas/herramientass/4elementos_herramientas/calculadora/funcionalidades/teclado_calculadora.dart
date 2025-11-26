/// TECLADO Y ACCIONES
/// Ensambla la grilla numérica y de operadores utilizando el `BotonCalculadora`.
/// Incluye también la fila inferior de acciones especiales (% y Raíz).
import 'package:flutter/material.dart';
import 'logica_calculadora.dart';
import 'boton_calculadora.dart';
import 'utils_calculadora.dart';

class TecladoCalculadora extends StatelessWidget {
  final CalculadoraController controller;
  final VoidCallback onStateChanged;

  const TecladoCalculadora({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Fila 1: AC, CE, Borrar, Dividir
          Row(
            children: [
              BotonCalculadora(
                label: 'AC',
                colorBorde: UtilsCalculadora.btnRojoBorde,
                colorTexto: UtilsCalculadora.btnRojoTexto,
                onTap: () { controller.clearAll(); onStateChanged(); },
              ),
              BotonCalculadora(
                label: 'CE',
                colorBorde: UtilsCalculadora.btnNaranjaBorde,
                colorTexto: UtilsCalculadora.btnNaranjaTexto,
                onTap: () { controller.clearEntry(); onStateChanged(); },
              ),
              BotonCalculadora(
                label: '⌫',
                colorBorde: UtilsCalculadora.btnNaranjaBorde,
                colorTexto: UtilsCalculadora.btnAmarilloTexto,
                onTap: () { controller.delete(); onStateChanged(); },
              ),
              BotonCalculadora(
                label: '÷',
                esVerde: true,
                onTap: () { controller.input('/'); onStateChanged(); },
              ),
            ],
          ),
          // Fila 2: 7, 8, 9, Multiplicar
          Row(
            children: [
              BotonCalculadora(label: '7', onTap: () { controller.input('7'); onStateChanged(); }),
              BotonCalculadora(label: '8', onTap: () { controller.input('8'); onStateChanged(); }),
              BotonCalculadora(label: '9', onTap: () { controller.input('9'); onStateChanged(); }),
              BotonCalculadora(
                label: '×',
                esVerde: true,
                onTap: () { controller.input('*'); onStateChanged(); },
              ),
            ],
          ),
          // Fila 3: 4, 5, 6, Restar
          Row(
            children: [
              BotonCalculadora(label: '4', onTap: () { controller.input('4'); onStateChanged(); }),
              BotonCalculadora(label: '5', onTap: () { controller.input('5'); onStateChanged(); }),
              BotonCalculadora(label: '6', onTap: () { controller.input('6'); onStateChanged(); }),
              BotonCalculadora(
                label: '−',
                esVerde: true,
                onTap: () { controller.input('-'); onStateChanged(); },
              ),
            ],
          ),
          // Fila 4: 1, 2, 3, Sumar
          Row(
            children: [
              BotonCalculadora(label: '1', onTap: () { controller.input('1'); onStateChanged(); }),
              BotonCalculadora(label: '2', onTap: () { controller.input('2'); onStateChanged(); }),
              BotonCalculadora(label: '3', onTap: () { controller.input('3'); onStateChanged(); }),
              BotonCalculadora(
                label: '+',
                esVerde: true,
                onTap: () { controller.input('+'); onStateChanged(); },
              ),
            ],
          ),
          // Fila 5: 0, Punto, Igual
          Row(
            children: [
              BotonCalculadora(
                label: '0',
                flex: 2,
                onTap: () { controller.input('0'); onStateChanged(); },
              ),
              BotonCalculadora(label: '.', onTap: () { controller.input('.'); onStateChanged(); }),
              BotonCalculadora(
                label: '=',
                esVerde: true,
                colorFondoVerde: const Color(0xFF0B8F59),
                onTap: () { controller.calculate(); onStateChanged(); },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccionesInferioresCalculadora extends StatelessWidget {
  final CalculadoraController controller;
  final VoidCallback onStateChanged;

  const AccionesInferioresCalculadora({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildExtraButton('%', () { controller.percent(); onStateChanged(); }),
          const SizedBox(width: 12),
          _buildExtraButton('√', () { controller.sqrtCurrent(); onStateChanged(); }),
        ],
      ),
    );
  }

  Widget _buildExtraButton(String label, VoidCallback onTap) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: UtilsCalculadora.gradienteVerde,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: UtilsCalculadora.colorPrincipal.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // FocusScope.of(context).unfocus(); // Context no disponible directamente aquí, pero InkWell lo maneja
              onTap();
            },
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}