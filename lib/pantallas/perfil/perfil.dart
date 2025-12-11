/// ORQUESTADOR PRINCIPAL DE PERFIL
/// Coordina toda la pantalla:
/// - Maneja los controladores de estado, animaciones y formularios.
/// - Se comunica con Firebase (Auth, Storage, Firestore).
/// - Ensambla los componentes visuales modularizados.
/// - Controla el flujo de edición y guardado de datos.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
// CAMBIO: Importamos el servicio correcto
import '../../firebase/servicios/UsuarioService/usuarios_servicio.dart';
import '../principal/funcionalidades/foto_perfil_manager.dart';

// Importaciones modularizadas
import 'funcionalidades/app_bar_perfil.dart';
import 'funcionalidades/foto_perfil.dart';
import 'funcionalidades/formulario_info.dart';
// import 'funcionalidades/estadisticas_perfil.dart';
import 'funcionalidades/estados_perfil.dart';
import 'funcionalidades/modales_perfil.dart';
import 'funcionalidades/utils_perfil.dart';
import '../principal/funcionalidades/nombre_usuario_manager.dart';

class PantallaPerfil extends StatefulWidget {
  final bool iniciarEnEdicion;

  const PantallaPerfil({super.key, this.iniciarEnEdicion = false});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> with TickerProviderStateMixin {
  // CAMBIO: Usamos UsuariosServicio
  final UsuariosServicio _usuariosServicio = UsuariosServicio();
  // final PrincipalServicio _principalServicio = PrincipalServicio();
  
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _biografiaController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _loadingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _estaCargando = false;
  bool _modoEdicion = false;
  bool _guardando = false;
  String? _urlFotoPerfil;
  
  Map<String, dynamic> _datosUsuario = {
    'nombre': '',
    'email': '',
    'biografia': '',
    'fechaRegistro': null,
    'ultimoAcceso': null,
  };



  @override
  void initState() {
    super.initState();
    _modoEdicion = widget.iniciarEnEdicion;
    _initializeAnimations();
    _cargarDatosUsuario();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _loadingController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack)),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _biografiaController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() => _estaCargando = !widget.iniciarEnEdicion);

    try {
      final user = FirebaseAuth.instance.currentUser;
      // Intentamos cargar datos extras de Firestore
      final perfilDoc = await _usuariosServicio.obtenerPerfil();
      final datosFirestore = perfilDoc?.data() ?? {};

      if (user != null) {
        _datosUsuario = {
          'nombre': datosFirestore['nombre'] ?? user.displayName ?? '',
          'email': datosFirestore['email'] ?? user.email ?? '',
          'biografia': datosFirestore['biografia'] ?? '',
          'fechaRegistro': user.metadata.creationTime,
          'ultimoAcceso': user.metadata.lastSignInTime,
        };

        _nombreController.text = _datosUsuario['nombre'];
        _emailController.text = _datosUsuario['email'];
        _biografiaController.text = _datosUsuario['biografia'];
        
        // Priorizar foto de Firestore si existe, sino la de Auth
        _urlFotoPerfil = datosFirestore['fotoUrl'] ?? user.photoURL;


      }
    } catch (e) {
      _mostrarMensaje('Error al cargar los datos del perfil', esError: true);
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  Future<void> _guardarSoloNombre(String nuevoNombre) async {
    if (nuevoNombre.trim().length < 2) {
      throw Exception('El nombre debe tener al menos 2 caracteres');
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Actualizar Auth (DisplayName)
        if (nuevoNombre != user.displayName) {
          await user.updateDisplayName(nuevoNombre);
        }
        
        // Actualizar Firestore usando UsuariosServicio
        await _usuariosServicio.actualizarPerfil({
          'nombre': nuevoNombre,
        });
        
        // Actualizar estado local
        _datosUsuario['nombre'] = nuevoNombre;
        
        _mostrarMensaje('Nombre actualizado correctamente');
  // Notificar cambio global de nombre
  NombreUsuarioManager().notificarCambioNombre(nuevoNombre);
      }
    } catch (e) {
      _mostrarMensaje('Error al guardar el nombre: $e', esError: true);
      rethrow;
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_nombreController.text.trim().length < 2) {
      _mostrarMensaje('El nombre debe tener al menos 2 caracteres', esError: true);
      return;
    }

    setState(() => _guardando = true);
    _loadingController.repeat();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Actualizar Auth (DisplayName)
        if (_nombreController.text != user.displayName) {
          await user.updateDisplayName(_nombreController.text);
        }
        
        // CAMBIO: Actualizar Firestore usando UsuariosServicio
        await _usuariosServicio.actualizarPerfil({
          'nombre': _nombreController.text,
          'biografia': _biografiaController.text,
          // 'email': _emailController.text // Generalmente el email se actualiza por otro proceso de Auth
        });
        
        // Actualizar estado local
        _datosUsuario['nombre'] = _nombreController.text;
        _datosUsuario['email'] = _emailController.text;
        _datosUsuario['biografia'] = _biografiaController.text;

        setState(() => _modoEdicion = false);
        _mostrarMensaje('Perfil actualizado correctamente');
        if (mounted) Navigator.pop(context, true); // Retorna true para indicar cambio
      }
    } catch (e) {
      _mostrarMensaje('Error al guardar los cambios', esError: true);
    } finally {
      _loadingController.stop();
      _loadingController.reset();
      setState(() => _guardando = false);
    }
  }

  Future<void> _procesarFoto(ImageSource source) async {
    try {
      setState(() => _guardando = true);
      _loadingController.repeat();
      
      final XFile? foto = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (foto != null) {
        await _subirImagenYActualizar(File(foto.path));
      } else {
        setState(() => _guardando = false);
        _loadingController.stop();
        _loadingController.reset();
      }
    } catch (e) {
      print('Error al procesar foto: $e');
      _mostrarMensaje('Error al seleccionar la foto: ${e.toString()}', esError: true);
      setState(() => _guardando = false);
      _loadingController.stop();
      _loadingController.reset();
    }
  }

  Future<void> _subirImagenYActualizar(File imagenFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión nuevamente.');
      }

      print('Procesando imagen...');
      
      // Convertir imagen a Base64 (más pequeña)
      final bytes = await imagenFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      print('Imagen procesada, guardando en Firestore...');

      // Solo guardar en Firestore (Firebase Auth tiene límite de tamaño)
      await _usuariosServicio.actualizarPerfil({
        'fotoUrl': 'data:image/jpeg;base64,$base64String',
        'tieneImagenPersonalizada': true
      });
      
      // También actualizar el displayName para forzar refresh
      await user.updateDisplayName(_datosUsuario['nombre']);
      
      print('Firestore actualizado');

      final nuevaFotoUrl = 'data:image/jpeg;base64,$base64String';
      
      setState(() {
        _urlFotoPerfil = nuevaFotoUrl;
      });
      
      // Notificar el cambio globalmente
      FotoPerfilManager().notificarCambioFoto(nuevaFotoUrl);
      
      _mostrarMensaje('Foto actualizada correctamente');
    } catch (e) {
      print('Error al procesar imagen: $e');
      _mostrarMensaje('Error al actualizar la foto: ${e.toString()}', esError: true);
    } finally {
      setState(() => _guardando = false);
      _loadingController.stop();
      _loadingController.reset();
    }
  }

  Future<void> _eliminarFoto() async {
    try {
      setState(() => _guardando = true);
      _loadingController.repeat();
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Solo actualizar en Firestore
      await _usuariosServicio.actualizarPerfil({
        'fotoUrl': null,
        'tieneImagenPersonalizada': false
      });

      setState(() => _urlFotoPerfil = null);
      
      // Notificar el cambio globalmente
      FotoPerfilManager().notificarCambioFoto(null);
      
      _mostrarMensaje('Foto de perfil eliminada');
    } catch (e) {
      print('Error al eliminar foto: $e');
      _mostrarMensaje('Error al eliminar la foto', esError: true);
    } finally {
      setState(() => _guardando = false);
      _loadingController.stop();
      _loadingController.reset();
    }
  }

  void _cancelarEdicion() {
    setState(() {
      _modoEdicion = false;
      _nombreController.text = _datosUsuario['nombre'];
      _emailController.text = _datosUsuario['email'];
      _biografiaController.text = _datosUsuario['biografia'];
    });
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(esError ? Icons.error : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ]),
          backgroundColor: esError ? Colors.red : UtilsPerfil.colorPrincipal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilsPerfil.colorFondo,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _estaCargando
              ? EstadoCargandoPerfil(scaleAnimation: _scaleAnimation)
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    AppBarPerfil(
                      modoEdicion: _modoEdicion,
                      guardando: _guardando,
                      rotationAnimation: _rotationAnimation,
                      onCancelar: _cancelarEdicion,
                      onGuardar: _guardarCambios,
                      onEditar: () => setState(() => _modoEdicion = true),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          FotoPerfil(
                            urlFoto: _urlFotoPerfil,
                            modoEdicion: _modoEdicion,
                            scaleAnimation: _scaleAnimation,
                            nombreUsuario: _datosUsuario['nombre'] ?? 'Usuario',
                            onCambiarFoto: () => ModalesPerfil.mostrarOpcionesFoto(
                              context: context,
                              onCamara: () => _procesarFoto(ImageSource.camera),
                              onGaleria: () => _procesarFoto(ImageSource.gallery),
                              onEliminar: _eliminarFoto,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FormularioInformacion(
                            formKey: _formKey,
                            nombreController: _nombreController,
                            emailController: _emailController,
                            biografiaController: _biografiaController,
                            modoEdicion: _modoEdicion,
                            datosUsuario: _datosUsuario,
                            onRequestEdit: () => setState(() => _modoEdicion = true),
                            onGuardarNombre: _guardarSoloNombre,
                          ),
                          const SizedBox(height: 24),
                          // Se eliminó la sección de estadísticas de uso
                          // CAMBIO: Usamos el stream de UsuariosServicio
                          // Preferencias financieras eliminadas
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}