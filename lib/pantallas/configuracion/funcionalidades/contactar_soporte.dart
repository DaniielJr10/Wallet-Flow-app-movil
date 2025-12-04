/**
 * FUNCIONALIDAD: Contactar Soporte
 * 
 * Pantalla moderna y profesional que permite a los usuarios contactar
 * al equipo de soporte de Wallet Flow enviando correos electrónicos.
 * Incluye formulario completo con validaciones, categorías de problemas
 * y envío directo a walletfloww@gmail.com
 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactarSoporteScreen extends StatefulWidget {
  const ContactarSoporteScreen({super.key});

  @override
  State<ContactarSoporteScreen> createState() => _ContactarSoporteScreenState();
}

class _ContactarSoporteScreenState extends State<ContactarSoporteScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _categoriaSeleccionada = 'General';
  bool _enviandoCorreo = false;

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'General', 'icono': Icons.help_outline, 'color': const Color(0xFF10B981)},
    {'nombre': 'Error técnico', 'icono': Icons.bug_report, 'color': const Color(0xFFEF4444)},
    {'nombre': 'Problema de cuenta', 'icono': Icons.account_circle, 'color': const Color(0xFFF59E0B)},
    {'nombre': 'Sugerencia', 'icono': Icons.lightbulb_outline, 'color': const Color(0xFF3B82F6)},
    {'nombre': 'Seguridad', 'icono': Icons.security, 'color': const Color(0xFF8B5CF6)},
    {'nombre': 'Otro', 'icono': Icons.more_horiz, 'color': const Color(0xFF6B7280)},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _asuntoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  /// Envía el correo electrónico usando la aplicación de correo del dispositivo
  Future<void> _enviarCorreo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviandoCorreo = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'usuario@ejemplo.com';
      final userName = user?.displayName ?? 'Usuario de Wallet Flow';
      
      // Construir el cuerpo del correo
      final String cuerpoCorreo = '''
Asunto: ${_asuntoController.text.trim()}
Categoría: $_categoriaSeleccionada

Mensaje:
${_mensajeController.text.trim()}

---
Información del usuario:
Nombre: $userName
Email: $userEmail
Fecha: ${DateTime.now().toString()}
Dispositivo: Flutter App
''';

      // Crear la URL del mailto
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'walletfloww@gmail.com',
        queryParameters: {
          'subject': '[Soporte Wallet Flow] ${_asuntoController.text.trim()}',
          'body': cuerpoCorreo,
        },
      );

      // Intentar abrir la aplicación de correo
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        
        if (mounted) {
          _mostrarExito();
          _limpiarFormulario();
        }
      } else {
        if (mounted) {
          _mostrarError('No se pudo abrir la aplicación de correo. \n\nPor favor, envía tu consulta manualmente a: walletfloww@gmail.com');
        }
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error al enviar el correo: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _enviandoCorreo = false);
      }
    }
  }

  /// Muestra el diálogo de éxito
  void _mostrarExito() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('¡Mensaje enviado!'),
          ],
        ),
        content: const Text(
          'Tu mensaje se ha enviado correctamente a nuestro equipo de soporte. '
          'Te responderemos lo más pronto posible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo de error
  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Limpia el formulario después del envío
  void _limpiarFormulario() {
    _asuntoController.clear();
    _mensajeController.clear();
    setState(() => _categoriaSeleccionada = 'General');
  }

  /// Obtiene el color de la categoría seleccionada
  Color _getColorCategoria() {
    final categoria = _categorias.firstWhere(
      (cat) => cat['nombre'] == _categoriaSeleccionada,
      orElse: () => _categorias[0],
    );
    return categoria['color'] as Color;
  }

  /// Obtiene el ícono de la categoría seleccionada
  IconData _getIconoCategoria() {
    final categoria = _categorias.firstWhere(
      (cat) => cat['nombre'] == _categoriaSeleccionada,
      orElse: () => _categorias[0],
    );
    return categoria['icono'] as IconData;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : 'Usuario';
    final displayEmail = (user?.email?.isNotEmpty == true)
        ? user!.email!
        : 'correo@ejemplo.com';
    final initials = displayName.isNotEmpty ? displayName.trim()[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Contactar Soporte',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del usuario
                _buildUserHeader(initials, displayName, displayEmail),
                const SizedBox(height: 24),
                
                // Formulario principal
                _buildFormulario(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el header con información del usuario
  Widget _buildUserHeader(String initials, String displayName, String displayEmail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF10B981).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $displayName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cuéntanos cómo podemos ayudarte',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el formulario principal
  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de categoría
            _buildSelectorCategoria(),
            const SizedBox(height: 24),
            
            // Campo de asunto
            _buildCampoAsunto(),
            const SizedBox(height: 20),
            
            // Campo de mensaje
            _buildCampoMensaje(),
            const SizedBox(height: 24),
            
            // Información de contacto
            _buildInfoContacto(),
            const SizedBox(height: 24),
            
            // Botón de envío
            _buildBotonEnvio(),
          ],
        ),
      ),
    );
  }

  /// Construye el selector de categoría
  Widget _buildSelectorCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría del problema',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _getColorCategoria().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getColorCategoria().withOpacity(0.3)),
          ),
          child: DropdownButton<String>(
            value: _categoriaSeleccionada,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(_getIconoCategoria(), color: _getColorCategoria()),
            onChanged: (String? nuevaCategoria) {
              if (nuevaCategoria != null) {
                setState(() => _categoriaSeleccionada = nuevaCategoria);
              }
            },
            items: _categorias.map<DropdownMenuItem<String>>((categoria) {
              return DropdownMenuItem<String>(
                value: categoria['nombre'],
                child: Row(
                  children: [
                    Icon(
                      categoria['icono'] as IconData,
                      color: categoria['color'] as Color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      categoria['nombre'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Construye el campo de asunto
  Widget _buildCampoAsunto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asunto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _asuntoController,
          decoration: InputDecoration(
            hintText: 'Resumen breve de tu consulta',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(
              Icons.subject,
              color: Colors.grey.shade600,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, escribe un asunto';
            }
            if (value.trim().length < 5) {
              return 'El asunto debe tener al menos 5 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Construye el campo de mensaje
  Widget _buildCampoMensaje() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mensaje detallado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _mensajeController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Describe detalladamente tu problema o pregunta...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, describe tu consulta';
            }
            if (value.trim().length < 20) {
              return 'Por favor, proporciona más detalles (mínimo 20 caracteres)';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Construye la información de contacto
  Widget _buildInfoContacto() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información importante',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu mensaje se enviará a walletfloww@gmail.com. '
                  'Responderemos en un plazo de 24-48 horas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón de envío
  Widget _buildBotonEnvio() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _enviandoCorreo ? null : _enviarCorreo,
        icon: _enviandoCorreo
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(
          _enviandoCorreo ? 'Enviando...' : 'Enviar mensaje',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
    );
  }
}
