/// TÍTULO DE SECCIÓN
/// Componente visual que muestra el icono, el título "Notas Financieras"
/// y una breve descripción de la funcionalidad.
import 'package:flutter/material.dart';
import 'utils_notas.dart';

class HeaderNotas extends StatelessWidget {
  const HeaderNotas({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.note_alt_rounded, color: UtilsNotas.colorPrincipal, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Notas Financieras',
                style: TextStyle(
                  color: UtilsNotas.colorTextoTitulo,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                'Organiza y gestiona todas tus ideas y recordatorios financieros',
                style: TextStyle(fontSize: 12, color: UtilsNotas.colorTextoGris),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}