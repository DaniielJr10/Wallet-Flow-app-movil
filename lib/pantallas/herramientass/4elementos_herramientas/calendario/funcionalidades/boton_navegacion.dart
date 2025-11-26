/// BOTÓN DE NAVEGACIÓN
/// Widget pequeño e iconográfico usado para cambiar de mes o año.
/// Tiene un estilo sutil y feedback visual al tacto.
import 'package:flutter/material.dart';
import 'utils_calendario.dart';

class BotonNavegacion extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const BotonNavegacion({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 40,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: UtilsCalendario.colorPrincipal.withOpacity(0.14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: UtilsCalendario.colorPrincipal,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}