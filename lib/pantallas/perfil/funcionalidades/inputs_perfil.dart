/// WIDGETS DE ENTRADA DE TEXTO
/// Componente reutilizable para los campos del formulario de perfil.
/// Gestiona los estilos de borde, colores y estado (habilitado/deshabilitado)
/// para mantener una apariencia uniforme en toda la pantalla.
import 'package:flutter/material.dart';
import 'utils_perfil.dart';

class CampoTextoPerfil extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final bool habilitado;
  final TextInputType tipoTeclado;
  final int lineasMaximas;
  final String? Function(String?)? validador;

  const CampoTextoPerfil({
    super.key,
    required this.controller,
    required this.label,
    required this.icono,
    required this.habilitado,
    this.tipoTeclado = TextInputType.text,
    this.lineasMaximas = 1,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: habilitado,
      keyboardType: tipoTeclado,
      maxLines: lineasMaximas,
      validator: validador,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icono,
          color: habilitado ? UtilsPerfil.colorPrincipal : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UtilsPerfil.colorPrincipal, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        filled: true,
        fillColor: habilitado ? Colors.white : const Color(0xFFF9FAFB),
        labelStyle: TextStyle(
          color: habilitado ? const Color(0xFF374151) : Colors.grey,
        ),
      ),
      style: TextStyle(
        color: habilitado ? const Color(0xFF111827) : Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}