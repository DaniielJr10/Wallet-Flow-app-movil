import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../firebase/autenticacion_servicio.dart';
import '../firebase/base_datos_servicio.dart';

/// Pantalla de gestión de perfil de usuario en Wallet Flow
/// 
/// Permite al usuario visualizar y editar su información personal,
/// gestionar su foto de perfil, configurar preferencias personales
/// y revisar estadísticas de uso de la aplicación.
/// 
/// Características principales:
/// - Edición de información personal (nombre, email, teléfono)
/// - Gestión de foto de perfil con opciones de cámara/galería
/// - Configuración de preferencias financieras
/// - Estadísticas de uso y actividad
/// - Validación en tiempo real de formularios
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil>
    with TickerProviderStateMixin {

  // ===== SERVICIOS Y CONTROLADORES =====
  final AutenticacionServicio _authService = AutenticacionServicio();
  final BaseDatosServicio _baseDatosService = BaseDatosServicio();
  final ImagePicker _imagePicker = ImagePicker();
  
  /// Controlador principal de animaciones de la pantalla
  late AnimationController _animationController;
  
  /// Controlador para animaciones de carga
  late AnimationController _loadingController;
  
  // Animaciones principales
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // Animaciones de carga
  late Animation<double> _rotationAnimation;

  // ===== CONTROLADORES DE FORMULARIO =====
  /// Controlador global del formulario para validación
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// Controlador para el campo de nombre completo
  final TextEditingController _nombreController = TextEditingController();
  
  /// Controlador para el campo de email
  final TextEditingController _emailController = TextEditingController();
  
  /// Controlador para el campo de teléfono
  final TextEditingController _telefonoController = TextEditingController();
  
  /// Controlador para el campo de biografía/descripción
  final TextEditingController _biografiaController = TextEditingController();

  // ===== ESTADOS DE LA PANTALLA =====
  /// Indica si los datos del usuario están siendo cargados
  bool _estaCargando = false;
  
  /// Indica si el formulario está en modo de edición
  bool _modoEdicion = false;
  
  /// Indica si se está guardando información
  bool _guardando = false;
  
  /// URL de la foto de perfil del usuario
  String? _urlFotoPerfil;
  
  /// Datos estadísticos del usuario
  Map<String, dynamic> _estadisticas = {};

  // ===== DATOS DE USUARIO =====
  /// Información completa del usuario obtenida de Firebase
  Map<String, dynamic> _datosUsuario = {
    'nombre': '',
    'email': '',
    'telefono': '',
    'biografia': '',
    'fechaRegistro': null,
    'ultimoAcceso': null,
  };

  // ===== PREFERENCIAS FINANCIERAS =====
  /// Límite de gasto mensual del usuario
  double _limiteGastoMensual = 0.0;
  
  /// Categoría de gasto principal del usuario
  String _categoriaFavorita = 'General';

  /// Lista de categorías disponibles para seleccionar como favorita
  final List<String> _categorias = [
    'General',
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Educación',
    'Salud',
    'Compras',
    'Servicios',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarDatosUsuario();
  }

  /// Inicializa todas las animaciones de la pantalla
  void _initializeAnimations() {
    // Controlador principal para animaciones de entrada
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Controlador para animaciones de carga
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animación de desvanecimiento gradual
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Animación de deslizamiento desde abajo
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    // Animación de escalado suave
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    // Animación de rotación para indicadores de carga
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    // Iniciar animaciones
    _animationController.forward();
  }

  /// Carga todos los datos del usuario desde Firebase
  /// Incluye información personal, preferencias y estadísticas
  Future<void> _cargarDatosUsuario() async {
    setState(() {
      _estaCargando = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Cargar datos básicos del usuario
        _datosUsuario = {
          'nombre': user.displayName ?? '',
          'email': user.email ?? '',
          'telefono': '', // TODO: Obtener de Firestore
          'biografia': '', // TODO: Obtener de Firestore
          'fechaRegistro': user.metadata.creationTime,
          'ultimoAcceso': user.metadata.lastSignInTime,
        };

        // Actualizar controladores de texto
        _nombreController.text = _datosUsuario['nombre'];
        _emailController.text = _datosUsuario['email'];
        _telefonoController.text = _datosUsuario['telefono'];
        _biografiaController.text = _datosUsuario['biografia'];

        // Cargar foto de perfil
        _urlFotoPerfil = user.photoURL;

        // Cargar estadísticas del usuario
        await _cargarEstadisticas();

        // Cargar preferencias financieras
        await _cargarPreferenciasFinancieras();
      }
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
      _mostrarError('Error al cargar los datos del perfil');
    } finally {
      setState(() {
        _estaCargando = false;
      });
    }
  }

  /// Carga las estadísticas de uso del usuario
  /// TODO: Implementar con datos reales de Firestore
  Future<void> _cargarEstadisticas() async {
    // Simular carga de estadísticas
    await Future.delayed(const Duration(milliseconds: 300));
    
    _estadisticas = {
      'transaccionesTotales': 156,
      'gastoPromedio': 125000,
      'ahorroTotal': 890000,
      'categoriaMasUsada': 'Alimentación',
      'diasActivo': 45,
    };
  }

  /// Carga las preferencias financieras del usuario
  /// TODO: Implementar con datos reales de Firestore
  Future<void> _cargarPreferenciasFinancieras() async {
    // Simular carga de preferencias
    await Future.delayed(const Duration(milliseconds: 200));
    
    _limiteGastoMensual = 800000.0;

    _categoriaFavorita = 'Alimentación';
  }

  /// Valida todos los campos del formulario
  /// Retorna true si todos los campos son válidos
  bool _validarFormulario() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Validaciones adicionales personalizadas
    if (_nombreController.text.trim().length < 2) {
      _mostrarError('El nombre debe tener al menos 2 caracteres');
      return false;
    }

    if (_telefonoController.text.isNotEmpty && 
        !RegExp(r'^\+?[0-9]{10,}$').hasMatch(_telefonoController.text)) {
      _mostrarError('El número de teléfono no es válido');
      return false;
    }

    return true;
  }

  /// Guarda los cambios del perfil del usuario
  Future<void> _guardarCambios() async {
    if (!_validarFormulario()) return;

    setState(() {
      _guardando = true;
    });

    _loadingController.repeat(); // Iniciar animación de carga

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Actualizar nombre en Firebase Auth si cambió
        if (_nombreController.text != user.displayName) {
          await user.updateDisplayName(_nombreController.text);
        }

        // Actualizar email si cambió (requiere reautenticación)
        if (_emailController.text != user.email) {
          await _actualizarEmail(_emailController.text);
        }

        // Guardar datos adicionales en Firestore
        await _guardarDatosFirestore();

        // Actualizar estado local
        _datosUsuario['nombre'] = _nombreController.text;
        _datosUsuario['email'] = _emailController.text;
        _datosUsuario['telefono'] = _telefonoController.text;
        _datosUsuario['biografia'] = _biografiaController.text;

        // Salir del modo edición
        setState(() {
          _modoEdicion = false;
        });

        _mostrarExito('Perfil actualizado correctamente');
      }
    } catch (e) {
      debugPrint('Error al guardar cambios: $e');
      _mostrarError('Error al guardar los cambios. Intenta nuevamente.');
    } finally {
      _loadingController.stop();
      _loadingController.reset();
      setState(() {
        _guardando = false;
      });
    }
  }

  /// Actualiza el email del usuario con reautenticación
  Future<void> _actualizarEmail(String nuevoEmail) async {
    // TODO: Implementar proceso de reautenticación
    // Para cambiar email se requiere reautenticación del usuario
    debugPrint('Actualizando email a: $nuevoEmail');
  }

  /// Guarda datos adicionales del usuario en Firestore
  Future<void> _guardarDatosFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final datosParaGuardar = {
          'nombre': _nombreController.text,
          'telefono': _telefonoController.text,
          'biografia': _biografiaController.text,
          'limiteGastoMensual': _limiteGastoMensual,

          'categoriaFavorita': _categoriaFavorita,
          'fechaActualizacion': DateTime.now(),
        };

        // TODO: Implementar guardado real en Firestore
        // await _baseDatosService.actualizarPerfil(user.uid, datosParaGuardar);
        debugPrint('Datos guardados: $datosParaGuardar');
      }
    } catch (e) {
      debugPrint('Error al guardar en Firestore: $e');
      rethrow;
    }
  }

  /// Muestra opciones para cambiar la foto de perfil
  void _cambiarFotoPerfil() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de arrastre
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Cambiar Foto de Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Opciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOpcionFoto(
                  icono: Icons.camera_alt,
                  titulo: 'Cámara',
                  onTap: () => _tomarFotoCamera(),
                ),
                _buildOpcionFoto(
                  icono: Icons.photo_library,
                  titulo: 'Galería',
                  onTap: () => _seleccionarDeGaleria(),
                ),
                _buildOpcionFoto(
                  icono: Icons.delete,
                  titulo: 'Eliminar',
                  onTap: () => _eliminarFoto(),
                  esDestructivo: true,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Construye una opción para cambiar foto
  Widget _buildOpcionFoto({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
    bool esDestructivo = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: esDestructivo 
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: esDestructivo ? Colors.red : const Color(0xFF10B981),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: esDestructivo ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Toma una foto con la cámara
  Future<void> _tomarFotoCamera() async {
    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (foto != null) {
        await _subirImagenYActualizar(File(foto.path));
      }
    } catch (e) {
      _mostrarError('Error al tomar la foto: $e');
    }
  }

  /// Selecciona una foto de la galería
  Future<void> _seleccionarDeGaleria() async {
    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (foto != null) {
        await _subirImagenYActualizar(File(foto.path));
      }
    } catch (e) {
      _mostrarError('Error al seleccionar la foto: $e');
    }
  }

  /// Sube la imagen a Firebase Storage y actualiza el perfil
  Future<void> _subirImagenYActualizar(File imagenFile) async {
    try {
      setState(() {
        _guardando = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear referencia en Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('perfil_fotos')
          .child('${user.uid}.jpg');

      // Subir archivo
      await storageRef.putFile(imagenFile);
      
      // Obtener URL de descarga
      final downloadURL = await storageRef.getDownloadURL();

      // Actualizar perfil en Firebase Auth
      await user.updatePhotoURL(downloadURL);

      // Actualizar en Firestore también
      await _baseDatosService.actualizarPerfilUsuario({
        'fotoUrl': downloadURL,
      });

      setState(() {
        _urlFotoPerfil = downloadURL;
      });

      _mostrarInfo('Foto de perfil actualizada correctamente');
    } catch (e) {
      _mostrarError('Error al actualizar la foto: $e');
    } finally {
      setState(() {
        _guardando = false;
      });
    }
  }

  /// Elimina la foto de perfil actual
  void _eliminarFoto() {
    setState(() {
      _urlFotoPerfil = null;
    });
    _mostrarInfo('Foto de perfil eliminada');
  }

  /// Cancela la edición y restaura valores originales
  void _cancelarEdicion() {
    setState(() {
      _modoEdicion = false;
      
      // Restaurar valores originales
      _nombreController.text = _datosUsuario['nombre'];
      _emailController.text = _datosUsuario['email'];
      _telefonoController.text = _datosUsuario['telefono'];
      _biografiaController.text = _datosUsuario['biografia'];
    });
  }

  // ===== MÉTODOS DE UTILIDAD =====

  /// Muestra un mensaje de error al usuario
  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Muestra un mensaje de éxito al usuario
  void _mostrarExito(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Muestra un mensaje informativo al usuario
  void _mostrarInfo(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: const Color(0xFF3B82F6),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Formatea números en formato de moneda colombiana
  String _formatearMoneda(double valor) {
    return '\$${valor.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  /// Formatea fechas en formato legible
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No disponible';
    
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _biografiaController.dispose();
    super.dispose();
  }

  // ===== CONSTRUCCIÓN DE UI =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _estaCargando
              ? _buildCargando()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildFotoPerfil(),
                          const SizedBox(height: 24),
                          _buildFormularioInformacion(),
                          const SizedBox(height: 24),
                          _buildEstadisticas(),
                          const SizedBox(height: 24),
                          _buildPreferenciasFinancieras(),
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

  /// Construye la pantalla de carga
  Widget _buildCargando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cargando tu perfil...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  /// Construye la barra de aplicación con acciones
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      elevation: 0,
      actions: [
        if (_modoEdicion) ...[
          // Botón cancelar
          IconButton(
            onPressed: _cancelarEdicion,
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Cancelar',
          ),
          // Botón guardar
          if (_guardando)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            )
          else
            IconButton(
              onPressed: _guardarCambios,
              icon: const Icon(Icons.save, color: Colors.white),
              tooltip: 'Guardar cambios',
            ),
        ] else
          // Botón editar
          IconButton(
            onPressed: () {
              setState(() {
                _modoEdicion = true;
              });
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar perfil',
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _modoEdicion ? 'Editar Perfil' : 'Mi Perfil',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF334155),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la sección de foto de perfil
  Widget _buildFotoPerfil() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Stack(
          children: [
            // Foto de perfil
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: const Color(0xFF10B981),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(56),
                child: _urlFotoPerfil != null
                    ? Image.network(
                        _urlFotoPerfil!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarPorDefecto();
                        },
                      )
                    : _buildAvatarPorDefecto(),
              ),
            ),
            
            // Botón para cambiar foto
            if (_modoEdicion)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _cambiarFotoPerfil,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construye el avatar por defecto
  Widget _buildAvatarPorDefecto() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(56),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  /// Construye el formulario de información personal
  Widget _buildFormularioInformacion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo nombre
            _buildCampoTexto(
              controller: _nombreController,
              label: 'Nombre Completo',
              icono: Icons.person,
              habilitado: _modoEdicion,
              validador: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo email
            _buildCampoTexto(
              controller: _emailController,
              label: 'Correo Electrónico',
              icono: Icons.email,
              habilitado: _modoEdicion,
              tipoTeclado: TextInputType.emailAddress,
              validador: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email es requerido';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Ingresa un email válido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo teléfono
            _buildCampoTexto(
              controller: _telefonoController,
              label: 'Teléfono (Opcional)',
              icono: Icons.phone,
              habilitado: _modoEdicion,
              tipoTeclado: TextInputType.phone,
              validador: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
                    return 'Ingresa un número válido (mín. 10 dígitos)';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo biografía
            _buildCampoTexto(
              controller: _biografiaController,
              label: 'Acerca de ti (Opcional)',
              icono: Icons.info_outline,
              habilitado: _modoEdicion,
              lineasMaximas: 3,
              validador: (value) {
                if (value != null && value.length > 200) {
                  return 'Máximo 200 caracteres';
                }
                return null;
              },
            ),

            // Información de registro
            if (!_modoEdicion) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              
              _buildInfoItem(
                'Fecha de registro',
                _formatearFecha(_datosUsuario['fechaRegistro']),
                Icons.calendar_today,
              ),
              
              const SizedBox(height: 12),
              
              _buildInfoItem(
                'Último acceso',
                _formatearFecha(_datosUsuario['ultimoAcceso']),
                Icons.access_time,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construye un campo de texto personalizado
  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    required bool habilitado,
    TextInputType tipoTeclado = TextInputType.text,
    int lineasMaximas = 1,
    String? Function(String?)? validador,
  }) {
    return TextFormField(
      controller: controller,
      enabled: habilitado,
      keyboardType: tipoTeclado,
      maxLines: lineasMaximas,
      validator: validador,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icono,
          color: habilitado ? const Color(0xFF10B981) : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        filled: true,
        fillColor: habilitado ? Colors.white : const Color(0xFFF9FAFB),
        labelStyle: TextStyle(
          color: habilitado ? const Color(0xFF374151) : Colors.grey,
        ),
      ),
      style: TextStyle(
        color: habilitado ? const Color(0xFF111827) : Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Construye un elemento de información no editable
  Widget _buildInfoItem(String titulo, String valor, IconData icono) {
    return Row(
      children: [
        Icon(
          icono,
          color: const Color(0xFF6B7280),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          valor,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Construye la sección de estadísticas
  Widget _buildEstadisticas() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estadísticas de Uso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Grid de estadísticas
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildEstadisticaCard(
                'Transacciones',
                '${_estadisticas['transaccionesTotales'] ?? 0}',
                Icons.receipt_long,
                const Color(0xFF10B981),
              ),
              _buildEstadisticaCard(
                'Gasto Promedio',
                _formatearMoneda(_estadisticas['gastoPromedio']?.toDouble() ?? 0),
                Icons.trending_down,
                const Color(0xFFEF4444),
              ),
              _buildEstadisticaCard(
                'Ahorro Total',
                _formatearMoneda(_estadisticas['ahorroTotal']?.toDouble() ?? 0),
                Icons.savings,
                const Color(0xFF3B82F6),
              ),
              _buildEstadisticaCard(
                'Días Activo',
                '${_estadisticas['diasActivo'] ?? 0}',
                Icons.calendar_month,
                const Color(0xFFF59E0B),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Categoría más usada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF7C3AED),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categoría Favorita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _estadisticas['categoriaMasUsada'] ?? 'General',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de estadística individual
  Widget _buildEstadisticaCard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye la sección de preferencias financieras
  Widget _buildPreferenciasFinancieras() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Preferencias Financieras',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Límite de gasto mensual
          _buildPreferenciaItem(
            titulo: 'Límite de Gasto Mensual',
            valor: _formatearMoneda(_limiteGastoMensual),
            icono: Icons.account_balance_wallet,
            color: const Color(0xFFEF4444),
            onTap: _modoEdicion ? () => _editarLimiteGasto() : null,
          ),



          const SizedBox(height: 16),

          // Categoría favorita
          _buildPreferenciaItem(
            titulo: 'Categoría Favorita',
            valor: _categoriaFavorita,
            icono: Icons.category,
            color: const Color(0xFF3B82F6),
            onTap: _modoEdicion ? () => _editarCategoriaFavorita() : null,
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de preferencia
  Widget _buildPreferenciaItem({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.edit,
                color: color.withOpacity(0.6),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // ===== MÉTODOS DE EDICIÓN DE PREFERENCIAS =====

  /// Permite editar el límite de gasto mensual
  void _editarLimiteGasto() {
    _mostrarDialogoNumerico(
      titulo: 'Límite de Gasto Mensual',
      valorActual: _limiteGastoMensual,
      onGuardar: (nuevoValor) {
        setState(() {
          _limiteGastoMensual = nuevoValor;
        });
      },
    );
  }


  /// Permite editar la categoría favorita
  void _editarCategoriaFavorita() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Seleccionar Categoría Favorita'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _categorias.length,
            itemBuilder: (context, index) {
              final categoria = _categorias[index];
              final esSeleccionada = categoria == _categoriaFavorita;
              
              return ListTile(
                title: Text(categoria),
                trailing: esSeleccionada
                    ? const Icon(Icons.check, color: Color(0xFF10B981))
                    : null,
                onTap: () {
                  setState(() {
                    _categoriaFavorita = categoria;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo para editar valores numéricos
  void _mostrarDialogoNumerico({
    required String titulo,
    required double valorActual,
    required Function(double) onGuardar,
  }) {
    final controller = TextEditingController(
      text: valorActual.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(titulo),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Valor en COP',
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nuevoValor = double.tryParse(controller.text) ?? 0.0;
              onGuardar(nuevoValor);
              Navigator.pop(context);
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }
}
