// Input de contraseña con icono de "ojo" para mostrar/ocultar
import 'package:flutter/material.dart';
import 'utils_login.dart';

class CampoPassword extends StatefulWidget {
  final TextEditingController controller;
  final Function() onSubmitted;

  const CampoPassword({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  State<CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<CampoPassword> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UtilsLogin.colorPrincipal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        validator: UtilsLogin.validatePassword,
        onFieldSubmitted: (_) => widget.onSubmitted(),
        decoration: InputDecoration(
          labelText: 'Contraseña',
          hintText: 'Ingresa tu contraseña',
          prefixIcon: const Icon(Icons.lock_outline, color: UtilsLogin.colorSecundario),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: UtilsLogin.colorSecundario,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(color: UtilsLogin.colorTexto, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(color: const Color(0xFF6B7280).withOpacity(0.7)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsLogin.colorPrincipal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsLogin.colorError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsLogin.colorError, width: 2),
          ),
        ),
      ),
    );
  }
}