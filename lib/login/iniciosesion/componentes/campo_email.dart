// Input de correo electrónico con validación
import 'package:flutter/material.dart';
import 'utils_login.dart';

class CampoEmail extends StatelessWidget {
  final TextEditingController controller;

  const CampoEmail({super.key, required this.controller});

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
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: UtilsLogin.validateEmail,
        decoration: InputDecoration(
          labelText: 'Correo electrónico',
          hintText: 'ejemplo@correo.com',
          prefixIcon: const Icon(Icons.email_outlined, color: UtilsLogin.colorSecundario),
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