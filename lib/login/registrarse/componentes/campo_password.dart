/// INPUT DE CONTRASEÑA
/// Maneja la visibilidad de la contraseña con un botón de ojo interno.
import 'package:flutter/material.dart';
import 'utils_registro.dart';

class CampoPassword extends StatefulWidget {
  final TextEditingController controller;

  const CampoPassword({super.key, required this.controller});

  @override
  State<CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<CampoPassword> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UtilsRegistro.colorPrincipal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        textInputAction: TextInputAction.next,
        validator: UtilsRegistro.validatePassword,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          hintText: 'Mínimo 8 caracteres, Mayus, Num',
          prefixIcon: const Icon(Icons.lock_outline, color: UtilsRegistro.colorSecundario),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: UtilsRegistro.colorSecundario,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(color: UtilsRegistro.colorTexto, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(color: const Color(0xFF6B7280).withOpacity(0.7)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsRegistro.colorPrincipal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsRegistro.colorError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsRegistro.colorError, width: 2),
          ),
        ),
      ),
    );
  }
}