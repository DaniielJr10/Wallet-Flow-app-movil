/// ORQUESTADOR PRINCIPAL
/// Gestiona los controladores del formulario, el estado de carga y la
/// comunicación con Firebase Authentication.
import 'package:flutter/material.dart';
import '../../firebase/autenticacion_servicio.dart';

// Importaciones modulares
import 'componentes/layout_background.dart';
import 'componentes/header_logo.dart';
import 'componentes/header_titulo.dart';
import 'componentes/campo_nombre.dart';
import 'componentes/campo_email.dart';
import 'componentes/campo_password.dart';
import 'componentes/campo_confirmar.dart';
import 'componentes/boton_registrar.dart';
import 'componentes/link_login.dart';
import 'componentes/utils_registro.dart';

class RegistrarseScreen extends StatefulWidget {
  const RegistrarseScreen({super.key});

  @override
  State<RegistrarseScreen> createState() => _RegistrarseScreenState();
}

class _RegistrarseScreenState extends State<RegistrarseScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AutenticacionServicio();
      final error = await authService.registrarUsuario(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombre: _nameController.text.trim(),
      );
      
      if (mounted) {
        if (error != null) {
          _showSnackBar(error, UtilsRegistro.colorError);
          setState(() => _isLoading = false);
        } else {
          setState(() => _isLoading = false);
          _showSnackBar(
            '¡Cuenta creada exitosamente! Bienvenido a Wallet Flow',
            UtilsRegistro.colorPrincipal,
          );
          
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(
          'Error de conexión. Verifica tu internet e intenta nuevamente',
          UtilsRegistro.colorError,
        );
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
              
              CampoNombre(controller: _nameController),
              const SizedBox(height: 20),
              
              CampoEmail(controller: _emailController),
              const SizedBox(height: 20),
              
              CampoPassword(controller: _passwordController),
              const SizedBox(height: 20),
              
              CampoConfirmarPassword(
                controller: _confirmPasswordController,
                passwordController: _passwordController,
                onSubmitted: _handleRegister,
              ),
              const SizedBox(height: 32),
              
              BotonRegistrar(
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 24),
              
              LinkLogin(
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