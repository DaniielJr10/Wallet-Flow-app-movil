import 'package:flutter/material.dart';
import '../firebase/autenticacion_servicio.dart';

/// Pantalla de registro de Wallet Flow
/// Presenta un diseño moderno y responsivo para crear cuenta nueva
class RegistrarseScreen extends StatefulWidget {
  const RegistrarseScreen({super.key});

  @override
  State<RegistrarseScreen> createState() => _RegistrarseScreenState();
}

class _RegistrarseScreenState extends State<RegistrarseScreen> {
  // Controladores para los campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Clave del formulario para validación
  final _formKey = GlobalKey<FormState>();
  
  // Estados para mostrar/ocultar contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Estado de carga
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida el nombre completo
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre completo';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    return null;
  }

  /// Valida el formato del email y que tenga un dominio válido
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    
    // Validar que el dominio sea conocido y real
    final domain = value.toLowerCase().split('@')[1];
    final dominiosValidos = [
      'gmail.com',
      'hotmail.com',
      'outlook.com',
      'yahoo.com',
      'yahoo.es',
      'icloud.com',
      'live.com',
      'msn.com',
      'protonmail.com',
      'zoho.com',
      'aol.com',
      'mail.com',
      'yandex.com',
      'tutanota.com',
      'fastmail.com',
      // Dominios corporativos comunes
      'empresa.com',
      'company.com',
      'corp.com',
      // Dominios educativos
      'soy.sena.edu.co',
      'edu.co',
      'edu',
      'ac.uk',
      'edu.mx',
      'edu.ar',
    ];
    
    if (!dominiosValidos.contains(domain)) {
      return 'Por favor usa un correo de un proveedor conocido\n(Gmail, Hotmail, Yahoo, etc.)';
    }
    
    return null;
  }

  /// Valida la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Debe contener mayúscula, minúscula y número';
    }
    
    return null;
  }

  /// Valida la confirmación de contraseña
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  /// Maneja el proceso de registro
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener el nombre completo del campo
      final nombreCompleto = _nameController.text.trim();
      
      print('Iniciando registro para: $nombreCompleto');
      
      // Usar el servicio de autenticación para registrar usuario
      final AutenticacionServicio authService = AutenticacionServicio();
      final error = await authService.registrarUsuario(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombre: nombreCompleto,
      );
      
      if (error != null) {
        // Si hay error, mostrarlo
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar(error, const Color(0xFFEF4444));
        }
        return;
      }
      
      print('Usuario creado exitosamente');
      
      if (mounted) {
        setState(() {
          _isLoading = false; // Parar loading inmediatamente
        });
        
        _showSnackBar(
          '¡Cuenta creada exitosamente! Bienvenido a Wallet Flow', 
          const Color(0xFF10B981)
        );
        
        // Regresar a la pantalla de login y notificar éxito
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
        return; // Salir aquí para evitar el finally
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showSnackBar(
          'Error de conexión. Verifica tu internet e intenta nuevamente', 
          const Color(0xFFEF4444)
        );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: constraints.maxHeight > 700 ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? size.width * 0.25 : 32,
                      vertical: 16,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 450 : double.infinity,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // ...eliminado botón de regreso...
                            const SizedBox(height: 8),
                            // Logo de la aplicación
                            _buildLogo(),
                            const SizedBox(height: 12),
                            // Título de la pantalla
                            _buildTitle(),
                            const SizedBox(height: 40),
                            // Campo de nombre
                            _buildNameField(),
                            const SizedBox(height: 20),
                            // Campo de correo electrónico
                            _buildEmailField(),
                            const SizedBox(height: 20),
                            // Campo de contraseña
                            _buildPasswordField(),
                            const SizedBox(height: 20),
                            // Campo de confirmar contraseña
                            _buildConfirmPasswordField(),
                            const SizedBox(height: 32),
                            // Botón de registrarse
                            _buildRegisterButton(),
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
              );
            },
          ),
        ),
      ),
    );
  }

  // ...eliminado _buildBackButton...

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
              Icons.person_add_outlined,
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
          'Crear Cuenta',
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
          'Únete a Wallet Flow y toma el control total de tus finanzas personales.',
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

  /// Construye el campo de nombre
  Widget _buildNameField() {
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
        controller: _nameController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        validator: _validateName,
        decoration: InputDecoration(
          labelText: 'Nombre completo',
          hintText: 'Ingresa tu nombre completo',
          prefixIcon: const Icon(
            Icons.person_outline,
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
        textInputAction: TextInputAction.next,
        validator: _validatePassword,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          hintText: 'Mínimo 8 caracteres',
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

  /// Construye el campo de confirmar contraseña
  Widget _buildConfirmPasswordField() {
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
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        validator: _validateConfirmPassword,
        onFieldSubmitted: (_) => _handleRegister(),
        decoration: InputDecoration(
          labelText: 'Confirmar contraseña',
          hintText: 'Repite tu contraseña',
          prefixIcon: const Icon(
            Icons.lock_clock_outlined,
            color: Color(0xFF059669),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF059669),
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
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

  /// Construye el botón de registro
  Widget _buildRegisterButton() {
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
        onPressed: _isLoading ? null : _handleRegister,
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
                    Icons.person_add_rounded,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Registrarse',
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
          '¿Ya tienes una cuenta? ',
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
