/// ORQUESTADOR PRINCIPAL DE PERFIL
/// Coordina toda la pantalla:
/// - Maneja los controladores de estado, animaciones y formularios.
/// - Se comunica con Firebase (Auth, Storage, Firestore).
/// - Ensambla los componentes visuales modularizados.
/// - Controla el flujo de edición y guardado de datos.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/base_datos_servicio.dart';
import '../../firebase/servicios/PrincipalService/principal_servicio.dart';

// Importaciones modularizadas
import 'funcionalidades/app_bar_perfil.dart';
import 'funcionalidades/foto_perfil.dart';
import 'funcionalidades/formulario_info.dart';
import 'funcionalidades/estadisticas_perfil.dart';
import 'funcionalidades/preferencias_perfil.dart';
import 'funcionalidades/estados_perfil.dart';
import 'funcionalidades/modales_perfil.dart';
import 'funcionalidades/utils_perfil.dart';

class PantallaPerfil extends StatefulWidget {
  final bool iniciarEnEdicion;

  const PantallaPerfil({super.key, this.iniciarEnEdicion = false});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> with TickerProviderStateMixin {
  final BaseDatosServicio _baseDatosService = BaseDatosServicio();
  final PrincipalServicio _principalServicio = PrincipalServicio();
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

  double _limiteGastoMensual = 0.0;
  String _categoriaFavorita = 'General';

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
      if (user != null) {
        // Simulación de carga de datos (Reemplazar con llamadas reales a Firestore si es necesario)
        _datosUsuario = {
          'nombre': user.displayName ?? '',
          'email': user.email ?? '',
          'biografia': '', // TODO: Obtener de Firestore
          'fechaRegistro': user.metadata.creationTime,
          'ultimoAcceso': user.metadata.lastSignInTime,
        };

        _nombreController.text = _datosUsuario['nombre'];
        _emailController.text = _datosUsuario['email'];
        _biografiaController.text = _datosUsuario['biografia'];
        _urlFotoPerfil = user.photoURL;

        // Simulaciones de datos extra (se mantienen algunas variables de UI)
        await Future.delayed(const Duration(milliseconds: 300));
        _limiteGastoMensual = 800000.0;
        _categoriaFavorita = 'Alimentación';
      }
    } catch (e) {
      _mostrarMensaje('Error al cargar los datos del perfil', esError: true);
    } finally {
      setState(() => _estaCargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validación adicional
    if (_nombreController.text.trim().length < 2) {
      _mostrarMensaje('El nombre debe tener al menos 2 caracteres', esError: true);
      return;
    }

    setState(() => _guardando = true);
    _loadingController.repeat();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (_nombreController.text != user.displayName) {
          await user.updateDisplayName(_nombreController.text);
        }
        // Aquí irían las llamadas a _actualizarEmail y guardado en Firestore
        
        // Actualizar local
        _datosUsuario['nombre'] = _nombreController.text;
        _datosUsuario['email'] = _emailController.text;
        _datosUsuario['biografia'] = _biografiaController.text;

        setState(() => _modoEdicion = false);
        _mostrarMensaje('Perfil actualizado correctamente');
        if (mounted) Navigator.pop(context, true);
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
      final XFile? foto = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (foto != null) {
        await _subirImagenYActualizar(File(foto.path));
      }
    } catch (e) {
      _mostrarMensaje('Error al procesar la foto', esError: true);
    }
  }

  Future<void> _subirImagenYActualizar(File imagenFile) async {
    try {
      setState(() => _guardando = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final storageRef = FirebaseStorage.instance.ref().child('perfil_fotos').child('${user.uid}.jpg');
      await storageRef.putFile(imagenFile);
      final downloadURL = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadURL);
      await _baseDatosService.actualizarPerfilUsuario({'fotoUrl': downloadURL});

      setState(() => _urlFotoPerfil = downloadURL);
      _mostrarMensaje('Foto actualizada correctamente');
    } catch (e) {
      _mostrarMensaje('Error al subir la foto', esError: true);
    } finally {
      setState(() => _guardando = false);
    }
  }

  void _eliminarFoto() {
    setState(() => _urlFotoPerfil = null);
    _mostrarMensaje('Foto de perfil eliminada');
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
                          ),
                          const SizedBox(height: 24),
                          StreamBuilder<Map<String, dynamic>>(
                            stream: _principalServicio.obtenerEstadisticasPerfilStream(),
                            builder: (context, snapshot) {
                              final stats = snapshot.data ?? {
                                'transaccionesTotales': 0,
                                'gastoPromedio': 0.0,
                                'ahorroTotal': 0.0,
                                'categoriaMasUsada': 'General',
                                'diasActivo': 0,
                              };
                              return EstadisticasPerfil(estadisticas: stats);
                            },
                          ),
                          const SizedBox(height: 24),
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                            stream: _baseDatosService.obtenerPerfilStream(),
                            builder: (context, snapPerfil) {
                              double limite = _limiteGastoMensual;
                              String categoria = _categoriaFavorita;

                              if (snapPerfil.hasData && snapPerfil.data != null && snapPerfil.data!.exists) {
                                final data = snapPerfil.data!.data() ?? {};
                                if (data['limiteGastoMensual'] != null) {
                                  final v = data['limiteGastoMensual'];
                                  if (v is num) limite = v.toDouble();
                                  else if (v is String) limite = double.tryParse(v) ?? limite;
                                }
                                if (data['categoriaFavorita'] != null) {
                                  categoria = data['categoriaFavorita'].toString();
                                }
                              }

                              return PreferenciasPerfil(
                                limiteGastoMensual: limite,
                                categoriaFavorita: categoria,
                                modoEdicion: _modoEdicion,
                                onEditarLimite: () => ModalesPerfil.mostrarDialogoNumerico(
                                  context: context,
                                  titulo: 'Límite de Gasto Mensual',
                                  valorActual: limite,
                                  onGuardar: (v) => _baseDatosService.actualizarPerfilUsuario({'limiteGastoMensual': v}),
                                ),
                                onEditarCategoria: () => ModalesPerfil.mostrarSelectorCategoria(
                                  context: context,
                                  categoriaActual: categoria,
                                  onSeleccionado: (v) => _baseDatosService.actualizarPerfilUsuario({'categoriaFavorita': v}),
                                ),
                              );
                            },
                          ),
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