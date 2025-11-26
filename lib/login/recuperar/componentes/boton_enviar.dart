/// BOTÓN DE ACCIÓN PRINCIPAL
/// Widget que maneja la interacción de envío. Cambia su estado visual
/// mostrando un indicador de carga (CircularProgressIndicator) cuando es necesario.
import 'package:flutter/material.dart';
import 'utils_recuperar.dart';

class BotonEnviar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const BotonEnviar({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UtilsRecuperar.colorPrincipal,
            UtilsRecuperar.colorSecundario,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: UtilsRecuperar.colorPrincipal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Enviar Código',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}