import 'package:flutter/material.dart';
import '../firebase/autenticacion_servicio.dart';
import '../pantallas/principal.dart';
import 'recuperar.dart';
import 'registrarse.dart';

/// Pantalla de inicio de sesión de Wallet Flow
/// Presenta un diseño moderno y responsivo con validación de campos
class InicioSesionScreen extends StatefulWidget {
  const InicioSesionScreen({super.key});

  @override
  State<InicioSesionScreen> createState() => _InicioSesionScreenState();
}

class _InicioSesionScreenState extends State<InicioSesionScreen> {
  // Servicio de autenticación de Firebase
  final AutenticacionServicio _authService = AutenticacionServicio();
  
  // Controladores para los campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Clave del formulario para validación
  final _formKey = GlobalKey<FormState>();
  
  // Estado para mostrar/ocultar contraseña
  bool _obscurePassword = true;
  
  // Estado de carga
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Valida el formato del email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    
    return null;
  }

  /// Valida la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  /// Maneja el proceso de inicio de sesión con Firebase
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Autenticación real con Firebase
      final String? error = await _authService.iniciarSesion(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        if (error == null) {
          // Éxito - usuario logueado
          _showSnackBar('¡Bienvenido a Wallet Flow!', const Color(0xFF10B981));
          
          // Navegar a la pantalla principal después de mostrar el mensaje
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const PantallaPrincipal(),
                ),
              );
            }
          });
        } else {
          // Error - mostrar mensaje específico
          _showSnackBar(error, const Color(0xFFEF4444));
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error inesperado: $e', const Color(0xFFEF4444));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Muestra un SnackBar con el mensaje especificado
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Navega a la pantalla de recuperación de contraseña
  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecuperarScreen(),
      ),
    );
  }

  /// Navega a la pantalla de registro
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrarseScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFE8F5E8), // Verde suave uniforme
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.25 : 32,
                vertical: 48,
              ),
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 450 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo de la aplicación
                      _buildLogo(),
                      
                      const SizedBox(height: 24),
                      
                      // Título de la aplicación
                      _buildTitle(),
                      
                      const SizedBox(height: 40),
                      
                      // Campo de correo electrónico
                      _buildEmailField(),
                      
                      const SizedBox(height: 20),
                      
                      // Campo de contraseña
                      _buildPasswordField(),
                      
                      const SizedBox(height: 32),
                      
                      // Botón de ingresar
                      _buildLoginButton(),
                      
                      const SizedBox(height: 24),
                      
                      // Enlace de olvidé mi contraseña
                      _buildForgotPasswordLink(),
                      
                      const SizedBox(height: 32),
                      
                      // Botón de registrarse
                      _buildRegisterButton(),
                      
                      const SizedBox(height: 20), // Espacio extra al final
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el logo de la aplicación
  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      child: Image.asset(
        'images/logo.png',
        fit: BoxFit.contain, // Mantiene la imagen sin recortar
        errorBuilder: (context, error, stackTrace) {
          // Fallback si no se encuentra la imagen
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10B981), Color(0xFF34D399)], // Verde elegante
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 50,
            ),
          );
        },
      ),
    );
  }

  /// Construye el título de la aplicación
  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Wallet Flow',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF065F46), // Verde oscuro elegante
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tus finanzas, bajo control',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF059669).withOpacity(0.8), // Verde medio
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Construye el campo de correo electrónico
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: _validateEmail,
        decoration: InputDecoration(
          labelText: 'Correo electrónico',
          hintText: 'ejemplo@correo.com',
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Color(0xFF059669),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF065F46),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: const Color(0xFF6B7280).withOpacity(0.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF10B981),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el campo de contraseña
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        validator: _validatePassword,
        onFieldSubmitted: (_) => _handleLogin(),
        decoration: InputDecoration(
          labelText: 'Contraseña',
          hintText: 'Ingresa tu contraseña',
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF059669),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF059669),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF065F46),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: const Color(0xFF6B7280).withOpacity(0.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF10B981),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el botón de inicio de sesión
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981), // Verde principal
            Color(0xFF059669), // Verde más oscuro
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'Ingresar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  /// Construye el enlace de olvidé mi contraseña
  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _navigateToForgotPassword,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: const Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(
          color: Color(0xFF059669),
          fontSize: 15,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF059669),
        ),
      ),
    );
  }

  /// Construye el botón de registro
  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: _navigateToRegister,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF059669),
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Registrarse',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
