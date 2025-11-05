import 'package:flutter/material.dart';

/// Pantalla de recuperar contraseña de Wallet Flow
/// Presenta un diseño moderno y responsivo para recuperación de contraseña
class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});

  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  // Controlador para el campo de correo
  final _emailController = TextEditingController();
  
  // Clave del formulario para validación
  final _formKey = GlobalKey<FormState>();
  
  // Estado de carga
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberar recursos del controlador
    _emailController.dispose();
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

  /// Maneja el proceso de envío del código de verificación
  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simular proceso de envío de código
      await Future.delayed(const Duration(seconds: 2));
      
      // Aquí iría la lógica real de envío de código
      // Por ejemplo: await AuthService.sendResetCode(_emailController.text);
      
      if (mounted) {
        _showSnackBar(
          'Código de verificación enviado a ${_emailController.text}', 
          const Color(0xFF10B981)
        );
        
        // Navegar a pantalla de verificación de código
        // Navigator.pushNamed(context, '/verify-code', arguments: _emailController.text);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error al enviar el código. Verifica tu correo e intenta nuevamente.', 
          const Color(0xFFEF4444)
        );
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

  /// Navega de regreso a la pantalla de inicio de sesión
  void _navigateBackToLogin() {
    Navigator.pop(context);
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
                      // Botón de regreso
                      _buildBackButton(),
                      
                      const SizedBox(height: 32),
                      
                      // Logo de la aplicación
                      _buildLogo(),
                      
                      const SizedBox(height: 24),
                      
                      // Título de la pantalla
                      _buildTitle(),
                      
                      const SizedBox(height: 40),
                      
                      // Campo de correo electrónico
                      _buildEmailField(),
                      
                      const SizedBox(height: 32),
                      
                      // Botón de enviar código
                      _buildSendCodeButton(),
                      
                      const SizedBox(height: 24),
                      
                      // Enlace para volver al login
                      _buildBackToLoginLink(),
                      
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

  /// Construye el botón de regreso
  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _navigateBackToLogin,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF059669),
                size: 24,
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
              Icons.shield_outlined,
              color: Colors.white,
              size: 50,
            ),
          );
        },
      ),
    );
  }

  /// Construye el título de la pantalla
  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Recuperar Contraseña',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF065F46), // Verde oscuro elegante
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Ingresa tu correo electrónico registrado y te enviaremos un código de verificación para restablecer tu contraseña.',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF059669).withOpacity(0.8), // Verde medio
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
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
        textInputAction: TextInputAction.done,
        validator: _validateEmail,
        onFieldSubmitted: (_) => _handleSendCode(),
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

  /// Construye el botón de enviar código
  Widget _buildSendCodeButton() {
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
        onPressed: _isLoading ? null : _handleSendCode,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.send_rounded,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Enviar Código',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Construye el enlace para volver al login
  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Recordaste tu contraseña? ',
          style: TextStyle(
            color: const Color(0xFF6B7280).withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: _navigateBackToLogin,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Inicia Sesión',
            style: TextStyle(
              color: Color(0xFF059669),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF059669),
            ),
          ),
        ),
      ],
    );
  }
}
