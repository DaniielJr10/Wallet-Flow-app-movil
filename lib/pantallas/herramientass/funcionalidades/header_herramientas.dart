/// TÍTULO DE SECCIÓN
/// Componente visual que muestra el icono grande y el título "HERRAMIENTAS".
/// Utiliza LayoutBuilder para adaptarse a diferentes anchos de pantalla.
import 'package:flutter/material.dart';
import 'utils_herramientas.dart';

class HeaderHerramientas extends StatelessWidget {
  const HeaderHerramientas({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(builder: (context, constraints) {
        final maxTextWidth = constraints.maxWidth * 0.74;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono decorativo desplazado
            Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: UtilsHerramientas.colorPrincipal,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'HERRAMIENTAS',
                    style: TextStyle(
                      color: UtilsHerramientas.colorPrincipal,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Accede a herramientas útiles para gestionar mejor tus finanzas',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}