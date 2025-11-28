/// ORQUESTADOR DE CALCULADORA
/// Pantalla principal de la herramienta. Ensambla el header, el display,
/// el teclado y las acciones inferiores. Utiliza el controlador para gestionar
/// la lógica y actualiza el estado de la UI.
import 'package:flutter/material.dart';

// Importaciones modularizadas
import 'funcionalidades/utils_calculadora.dart';
import 'funcionalidades/logica_calculadora.dart';
import 'funcionalidades/display_calculadora.dart';
import 'funcionalidades/teclado_calculadora.dart';

class CalculadoraPantalla extends StatefulWidget {
  const CalculadoraPantalla({super.key});

  @override
  State<CalculadoraPantalla> createState() => _CalculadoraPantallaState();
}

class _CalculadoraPantallaState extends State<CalculadoraPantalla> {
  final CalculadoraController _controller = CalculadoraController();

  // Esta es la API de la calculadora

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: UtilsCalculadora.gradienteFondo,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: UtilsCalculadora.colorFlechaBack),
                  ),
                  const Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calculate, color: UtilsCalculadora.colorPrincipal, size: 30),
                          SizedBox(width: 10),
                          Text(
                            'CALCULADORA',
                            style: TextStyle(
                              color: UtilsCalculadora.colorPrincipal,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Para equilibrar el botón de back
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Herramienta de cálculo financiero avanzada',
                style: TextStyle(color: UtilsCalculadora.colorTextoGris, fontSize: 13),
              ),
              const SizedBox(height: 18),

              // Card central con Display y Teclado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      DisplayCalculadora(
                        expression: _controller.expression,
                        result: _controller.result,
                      ),
                      const SizedBox(height: 12),
                      TecladoCalculadora(
                        controller: _controller,
                        onStateChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      AccionesInferioresCalculadora(
                        controller: _controller,
                        onStateChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// Aquí termina la API de la calculadora