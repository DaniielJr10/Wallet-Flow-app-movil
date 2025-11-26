/// HEADER DE PANTALLA
/// Contiene el botón de retroceso, el icono grande de calendario
/// y el título principal de la herramienta.
import 'package:flutter/material.dart';
import 'utils_calendario.dart';

class AppBarCalendario extends StatelessWidget {
  const AppBarCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          // Botón de retroceso
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: UtilsCalendario.colorPrincipal),
            tooltip: 'Volver',
          ),

          // Título centrado
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.calendar_month_rounded, color: UtilsCalendario.colorPrincipal, size: 34),
                    SizedBox(width: 8),
                    Text(
                      'CALENDARIO',
                      style: TextStyle(
                        color: UtilsCalendario.colorPrincipal,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Organiza y planifica tus fechas importantes',
                  style: TextStyle(fontSize: 13, color: UtilsCalendario.colorTextoGris),
                ),
              ],
            ),
          ),

          // Espacio para equilibrar el layout
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}