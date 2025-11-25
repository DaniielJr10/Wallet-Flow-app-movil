import 'package:flutter/material.dart';
import '../../firebase/autenticacion_servicio.dart';
import '../../pantallas/principal/principal.dart';
import '../recuperar/recuperar.dart';
import '../registrarse/registrarse.dart';

// Importaciones modularizadas
import 'componentes/layout_background.dart';
import 'componentes/header_logo.dart';
import 'componentes/header_titulo.dart';
import 'componentes/campo_email.dart';
import 'componentes/campo_password.dart';
import 'componentes/boton_ingresar.dart';
import 'componentes/boton_registro.dart';
import 'componentes/link_recuperar.dart';
import 'componentes/utils_login.dart';

class InicioSesionScreen extends StatefulWidget {
  const InicioSesionScreen({super.key});

  @override
  State<InicioSesionScreen> createState() => _InicioSesionScreenState();
}

class _InicioSesionScreenState extends State<InicioSesionScreen> {
  final AutenticacionServicio _authService = AutenticacionServicio();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? error = await _authService.iniciarSesion(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        if (error == null) {
          _showSnackBar('¡Bienvenido a Wallet Flow!', UtilsLogin.colorPrincipal);
          
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
              );
            }
          });
        } else {
          _showSnackBar(error, UtilsLogin.colorError);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error inesperado: $e', UtilsLogin.colorError);
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

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecuperarScreen()),
    );
  }

  void _navigateToRegister() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrarseScreen()),
    );

    if (result == true && mounted) {
      _showSnackBar(
        'Cuenta creada correctamente. Por favor inicia sesión.',
        UtilsLogin.colorPrincipal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBackground(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HeaderLogo(),
              const SizedBox(height: 24),
              const HeaderTitulo(),
              const SizedBox(height: 40),
              
              CampoEmail(controller: _emailController),
              const SizedBox(height: 20),
              
              CampoPassword(
                controller: _passwordController,
                onSubmitted: _handleLogin,
              ),
              const SizedBox(height: 32),
              
              BotonIngresar(
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),
              
              LinkRecuperarPassword(onTap: _navigateToForgotPassword),
              const SizedBox(height: 32),
              
              BotonRegistro(onPressed: _navigateToRegister),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}