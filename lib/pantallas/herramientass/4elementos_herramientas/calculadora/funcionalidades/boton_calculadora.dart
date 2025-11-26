/// WIDGET DE BOTÓN
/// Componente genérico para las teclas de la calculadora. Soporta dos estilos:
/// - Blanco (Números y acciones secundarias)
/// - Verde/Gradiente (Operadores principales)
import 'package:flutter/material.dart';
import 'utils_calculadora.dart';

class BotonCalculadora extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final int flex;
  final bool esVerde;
  final Color? colorBorde; // Solo para botones blancos
  final Color? colorTexto; // Solo para botones blancos
  final Color? colorFondoVerde; // Opcional para sobreescribir el verde default

  const BotonCalculadora({
    super.key,
    required this.label,
    required this.onTap,
    this.flex = 1,
    this.esVerde = false,
    this.colorBorde,
    this.colorTexto,
    this.colorFondoVerde,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SizedBox(
          height: 70,
          child: esVerde ? _buildGreenButton(context) : _buildWhiteButton(context),
        ),
      ),
    );
  }

  Widget _buildWhiteButton(BuildContext context) {
    final border = colorBorde ?? UtilsCalculadora.btnBlancoBorde;
    final text = colorTexto ?? const Color(0xFF1F2937);
    final isOutlined = colorBorde != null;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          onTap();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ).copyWith(overlayColor: MaterialStateProperty.all(Colors.transparent)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: text,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: border),
          padding: EdgeInsets.zero,
        ).copyWith(overlayColor: MaterialStateProperty.all(Colors.transparent)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      );
    }
  }

  Widget _buildGreenButton(BuildContext context) {
    final Color end = colorFondoVerde ?? UtilsCalculadora.colorPrincipal;
    
    return Container(
      decoration: BoxDecoration(
        gradient: colorFondoVerde != null 
            ? null // Si se pasa color específico (ej: igual), no usar gradiente por defecto
            : UtilsCalculadora.gradienteVerde,
        color: colorFondoVerde, // Usado si no hay gradiente
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: end.withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 6))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}