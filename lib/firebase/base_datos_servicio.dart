import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio que maneja toda la base de datos Firestore
/// Incluye: ahorros, gastos, cuentas, deudas, etc.
class BaseDatosServicio {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ID del usuario actual
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  
  /// AHORROS - Crear nuevo ahorro
  Future<String?> crearAhorro({
    required double montoObjetivo,
    required double montoActual,
    required DateTime fechaInicio,
    required DateTime fechaObjetivo,
    required String descripcion,
    required String categoria,
    String estado = 'pendiente',
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('ahorros')
          .add({
        'montoObjetivo': montoObjetivo,
        'montoActual': montoActual,
        'fechaInicio': fechaInicio,
        'fechaObjetivo': fechaObjetivo,
        'descripcion': descripcion,
        'categoria': categoria,
        'estado': estado,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito
    } catch (e) {
      return 'Error al crear ahorro: $e';
    }
  }
  
  /// AHORROS - Obtener todos los ahorros del usuario
  Stream<QuerySnapshot> obtenerAhorros() {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('ahorros')
        .orderBy('fechaCreacion', descending: true)
        .snapshots();
  }
  
  /// GASTOS - Crear nuevo gasto
  Future<String?> crearGasto({
    required String nombre,
    required double monto,
    required DateTime fecha,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
    String? nota,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('gastos')
          .add({
        'nombre': nombre,
        'monto': monto,
        'fecha': fecha,
        'categoria': categoria,
        'metodoPago': metodoPago,
        'cuentaAsociada': cuentaAsociada,
        'nota': nota,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito
    } catch (e) {
      return 'Error al crear gasto: $e';
    }
  }
  
  /// GASTOS - Obtener todos los gastos del usuario
  Stream<QuerySnapshot> obtenerGastos() {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('gastos')
        .orderBy('fecha', descending: true)
        .snapshots();
  }
  
  /// CUENTAS BANCARIAS - Crear nueva cuenta
  Future<String?> crearCuentaBancaria({
    required String nombreBanco,
    required String numeroCuenta,
    required String tipoCuenta,
    required String alias,
    required double saldoInicial,
    String categoria = 'personal',
    bool activa = true,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('cuentas')
          .add({
        'nombreBanco': nombreBanco,
        'numeroCuenta': numeroCuenta,
        'tipoCuenta': tipoCuenta,
        'alias': alias,
        'saldo': saldoInicial,
        'categoria': categoria,
        'activa': activa,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito
    } catch (e) {
      return 'Error al crear cuenta: $e';
    }
  }
  
  /// CUENTAS BANCARIAS - Obtener todas las cuentas del usuario
  Stream<QuerySnapshot> obtenerCuentas() {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('cuentas')
        .orderBy('fechaCreacion', descending: true)
        .snapshots();
  }
  
  /// DEUDAS - Crear nueva deuda
  Future<String?> crearDeuda({
    required String nombreAcreedor,
    required double montoTotal,
    required DateTime fechaInicio,
    required DateTime fechaVencimiento,
    required double montoPagado,
    double tasaInteres = 0.0,
    required String descripcion,
    String estado = 'pendiente',
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('deudas')
          .add({
        'nombreAcreedor': nombreAcreedor,
        'montoTotal': montoTotal,
        'fechaInicio': fechaInicio,
        'fechaVencimiento': fechaVencimiento,
        'montoPagado': montoPagado,
        'tasaInteres': tasaInteres,
        'descripcion': descripcion,
        'estado': estado,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito
    } catch (e) {
      return 'Error al crear deuda: $e';
    }
  }
  
  /// DEUDAS - Obtener todas las deudas del usuario
  Stream<QuerySnapshot> obtenerDeudas() {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('deudas')
        .orderBy('fechaVencimiento', descending: false)
        .snapshots();
  }
  
  /// PERFIL USUARIO - Guardar información adicional del usuario
  Future<String?> guardarPerfilUsuario({
    required String nombre,
    required String apellido,
    required String identificacion,
    required String telefono,
    required DateTime fechaNacimiento,
    required String nombreUsuario,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      await _firestore
          .collection('usuarios')
          .doc(_userId)
          .set({
        'nombre': nombre,
        'apellido': apellido,
        'identificacion': identificacion,
        'telefono': telefono,
        'fechaNacimiento': fechaNacimiento,
        'nombreUsuario': nombreUsuario,
        'email': FirebaseAuth.instance.currentUser?.email,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito
    } catch (e) {
      return 'Error al guardar perfil: $e';
    }
  }
  
  /// PERFIL USUARIO - Obtener información del usuario
  Future<DocumentSnapshot?> obtenerPerfilUsuario() async {
    try {
      if (_userId == null) return null;
      
      return await _firestore
          .collection('usuarios')
          .doc(_userId)
          .get();
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  /// PERFIL USUARIO - Actualizar información específica del usuario
  Future<String?> actualizarPerfilUsuario(Map<String, dynamic> datos) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      // Agregar timestamp de actualización
      datos['fechaActualizacion'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('usuarios')
          .doc(_userId)
          .update(datos);
      
      return null; // Éxito
    } catch (e) {
      return 'Error al actualizar perfil: $e';
    }
  }
}