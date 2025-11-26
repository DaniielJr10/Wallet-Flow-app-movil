/// ARCHIVO PRINCIPAL (ORQUESTADOR)
/// Maneja el estado de la pantalla (controladores, carga), la lógica de negocio
/// (llamada a Firebase Auth) y ensambla los componentes visuales.
import 'package:flutter/material.dart';
import '../../firebase/autenticacion_servicio.dart';

// Importación de componentes modularizados
import 'componentes/layout_background.dart';
import 'componentes/header_logo.dart';
import 'componentes/header_titulo.dart';
import 'componentes/campo_email.dart';
import 'componentes/boton_enviar.dart';
import 'componentes/link_volver.dart';
import 'componentes/utils_recuperar.dart';

class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});

  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  final AutenticacionServicio _authService = AutenticacionServicio();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? error = await _authService.recuperarPassword(
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        if (error == null) {
          _showSnackBar(
            'Email de recuperación enviado. Revisa tu bandeja de entrada y spam.',
            UtilsRecuperar.colorPrincipal,
          );
          
          // Regresar al login después de un momento
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          _showSnackBar(error, UtilsRecuperar.colorError);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error inesperado: $e', UtilsRecuperar.colorError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBackground(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const HeaderLogo(),
              const SizedBox(height: 12),
              const HeaderTitulo(),
              const SizedBox(height: 40),
              
              CampoEmail(
                controller: _emailController,
                onSubmitted: _handleSendCode,
              ),
              
              const SizedBox(height: 32),
              
              BotonEnviar(
                isLoading: _isLoading,
                onPressed: _handleSendCode,
              ),
              
              const SizedBox(height: 24),
              
              LinkVolverLogin(
                onTap: () => Navigator.pop(context),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}