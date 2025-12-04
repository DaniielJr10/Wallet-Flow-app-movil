import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contrasena_header.dart';
import 'contrasena_widgets.dart';
import 'contrasena_dialogs.dart';
import 'contrasena_validadores.dart';

class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  State<CambiarContrasenaScreen> createState() => _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentCtrl = TextEditingController();
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  // Controladores de animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _inicializarAnimaciones();
    
    // Agregar listener para actualizar el indicador de fuerza
    _newCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Inicializa las animaciones de la pantalla
  void _inicializarAnimaciones() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  /// Procesa el envío del formulario
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      if (mounted) {
        ContrasenaDialogs.mostrarErrorGenerico(context, 'Usuario no autenticado');
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text.trim());

      if (mounted) {
        await ContrasenaDialogs.mostrarDialogoExito(context);
        if (mounted) Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) ContrasenaDialogs.mostrarError(context, e);
    } catch (e) {
      if (mounted) {
        ContrasenaDialogs.mostrarErrorGenerico(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          'Cambiar Contraseña',
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
                const ContrasenaHeader(),
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
            // Campo contraseña actual
            ContrasenaWidgets.buildCampoContrasena(
              label: 'Contraseña actual',
              controller: _currentCtrl,
              obscureText: !_showCurrent,
              onToggleVisibility: () => setState(() => _showCurrent = !_showCurrent),
              icono: Icons.lock_outline,
              validator: ContrasenaValidadores.validarContrasenaActual,
            ),
            const SizedBox(height: 20),
            
            // Campo nueva contraseña
            ContrasenaWidgets.buildCampoContrasena(
              label: 'Nueva contraseña',
              controller: _newCtrl,
              obscureText: !_showNew,
              onToggleVisibility: () => setState(() => _showNew = !_showNew),
              icono: Icons.fingerprint,
              validator: ContrasenaValidadores.validarNuevaContrasena,
            ),
            const SizedBox(height: 8),
            
            // Indicador de fuerza de contraseña
            if (_newCtrl.text.isNotEmpty) ...[
              ContrasenaWidgets.buildIndicadorFuerza(_newCtrl.text),
              const SizedBox(height: 12),
            ],
            
            const SizedBox(height: 20),
            
            // Campo confirmar contraseña
            ContrasenaWidgets.buildCampoContrasena(
              label: 'Confirmar nueva contraseña',
              controller: _confirmCtrl,
              obscureText: !_showConfirm,
              onToggleVisibility: () => setState(() => _showConfirm = !_showConfirm),
              icono: Icons.check_circle_outline,
              validator: (v) => ContrasenaValidadores.validarConfirmacionContrasena(v, _newCtrl.text),
            ),
            const SizedBox(height: 24),
            
            // Información de seguridad
            ContrasenaWidgets.buildInfoSeguridad(),
            const SizedBox(height: 24),
            
            // Botón de actualización
            ContrasenaWidgets.buildBotonActualizar(
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
