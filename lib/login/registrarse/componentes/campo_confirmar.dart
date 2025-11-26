/// INPUT DE CONFIRMACIÓN
/// Verifica que el texto coincida con la contraseña original. Recibe el
/// controlador de la contraseña principal para hacer la comparación.
import 'package:flutter/material.dart';
import 'utils_registro.dart';

class CampoConfirmarPassword extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final Function() onSubmitted;

  const CampoConfirmarPassword({
    super.key,
    required this.controller,
    required this.passwordController,
    required this.onSubmitted,
  });

  @override
  State<CampoConfirmarPassword> createState() => _CampoConfirmarPasswordState();
}

class _CampoConfirmarPasswordState extends State<CampoConfirmarPassword> {
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
        textInputAction: TextInputAction.done,
        validator: (val) => UtilsRegistro.validateConfirmPassword(val, widget.passwordController.text),
        onFieldSubmitted: (_) => widget.onSubmitted(),
        decoration: InputDecoration(
          labelText: 'Confirmar contraseña',
          hintText: 'Repite tu contraseña',
          prefixIcon: const Icon(Icons.lock_clock_outlined, color: UtilsRegistro.colorSecundario),
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