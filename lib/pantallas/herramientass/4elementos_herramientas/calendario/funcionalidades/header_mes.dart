/// CONTROL DE NAVEGACIÓN DEL CALENDARIO
/// Muestra el Mes y Año actual, rodeado por botones para navegar
/// al mes/año anterior o siguiente.
import 'package:flutter/material.dart';
import 'utils_calendario.dart';
import 'boton_navegacion.dart';

class HeaderMes extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onPrevYear;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onNextYear;

  const HeaderMes({
    super.key,
    required this.focusedDay,
    required this.onPrevYear,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onNextYear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
      child: Row(
        children: [
          // Anterior
          BotonNavegacion(
            tooltip: 'Año anterior',
            icon: Icons.fast_rewind_rounded,
            onTap: onPrevYear,
          ),
          const SizedBox(width: 6),
          BotonNavegacion(
            tooltip: 'Mes anterior',
            icon: Icons.chevron_left_rounded,
            onTap: onPrevMonth,
          ),
          
          const Spacer(),
          
          // Título Central
          Column(
            children: [
              Text(
                UtilsCalendario.meses[focusedDay.month - 1],
                style: const TextStyle(
                  color: UtilsCalendario.colorTextoMes,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${focusedDay.year}',
                style: const TextStyle(
                  color: UtilsCalendario.colorPrincipal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Siguiente
          BotonNavegacion(
            tooltip: 'Mes siguiente',
            icon: Icons.chevron_right_rounded,
            onTap: onNextMonth,
          ),
          const SizedBox(width: 6),
          BotonNavegacion(
            tooltip: 'Año siguiente',
            icon: Icons.fast_forward_rounded,
            onTap: onNextYear,
          ),
        ],
      ),
    );
  }
}