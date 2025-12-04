import 'package:flutter/material.dart';
import 'soporte_modelos.dart';
import 'soporte_widgets_principales.dart';
import 'soporte_widgets_formulario.dart';
import 'soporte_email.dart';

/// Pantalla principal de contactar soporte modularizada
class ContactarSoportePantalla extends StatefulWidget {
  const ContactarSoportePantalla({super.key});

  @override
  State<ContactarSoportePantalla> createState() => _ContactarSoportePantallaState();
}

class _ContactarSoportePantallaState extends State<ContactarSoportePantalla>
    with TickerProviderStateMixin {
  
  // Controladores y claves
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  
  // Estado de la pantalla
  String _categoriaSeleccionada = 'General';
  bool _enviandoCorreo = false;
  
  // Controladores de animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _inicializarAnimaciones();
  }

  @override
  void dispose() {
    _asuntoController.dispose();
    _mensajeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Inicializa las animaciones de la pantalla
  void _inicializarAnimaciones() {
    _animationController = AnimationController(
      duration: SoporteConstantes.tiempoAnimacion,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  /// Maneja el envío del correo electrónico
  Future<void> _enviarCorreo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviandoCorreo = true);

    await SoporteEmailService.enviarCorreo(
      context: context,
      asunto: _asuntoController.text.trim(),
      categoria: _categoriaSeleccionada,
      mensaje: _mensajeController.text.trim(),
      onExito: _limpiarFormulario,
      onError: () {}, // Error se maneja en el servicio
    );

    if (mounted) {
      setState(() => _enviandoCorreo = false);
    }
  }

  /// Limpia el formulario después del envío exitoso
  void _limpiarFormulario() {
    _asuntoController.clear();
    _mensajeController.clear();
    setState(() => _categoriaSeleccionada = 'General');
  }

  @override
  Widget build(BuildContext context) {
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
                SoporteWidgetsPrincipales.buildUserHeader(),
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

  /// Construye el contenedor principal del formulario
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
            SoporteWidgetsFormulario.buildSelectorCategoria(
              categoriaSeleccionada: _categoriaSeleccionada,
              onChanged: (nuevaCategoria) {
                setState(() => _categoriaSeleccionada = nuevaCategoria);
              },
            ),
            const SizedBox(height: 24),
            
            // Campo de asunto
            SoporteWidgetsFormulario.buildCampoAsunto(
              controller: _asuntoController,
            ),
            const SizedBox(height: 20),
            
            // Campo de mensaje
            SoporteWidgetsFormulario.buildCampoMensaje(
              controller: _mensajeController,
            ),
            const SizedBox(height: 24),
            
            // Información de contacto
            SoporteWidgetsPrincipales.buildInfoContacto(context),
            const SizedBox(height: 24),
            
            // Botón de envío
            SoporteWidgetsPrincipales.buildBotonEnvio(
              enviandoCorreo: _enviandoCorreo,
              onPressed: _enviarCorreo,
            ),
          ],
        ),
      ),
    );
  }
}