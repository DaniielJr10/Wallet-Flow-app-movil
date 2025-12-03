/// SERVICIO SIMPLE DE FRECUENCIAS
/// Sistema sencillo: crea ingreso + programa automáticamente los siguientes
/// Usa subcollecciones usuarios/{uid}/ingresos como el resto del sistema
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../pantallas/ingresos/funcionalidades/frecuencia.dart';

class FrecuenciaServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Referencia a la subcollección de ingresos del usuario
  /// Estructura: usuarios/{uid}/ingresos
  CollectionReference<Map<String, dynamic>> _ingresosRef() {
    if (_userId == null) {
      return _firestore.collection('usuarios/__no_user__/ingresos');
    }
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('ingresos');
  }

  /// Crea un ingreso que se repetirá automáticamente según la frecuencia
  Future<String?> crearIngresoConFrecuencia({
    required double monto,
    required DateTime fechaInicial,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    required TipoFrecuencia frecuencia,
    String? cuentaAsociada,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';

      // Crear el ingreso normal + campos de repetición
      final datos = {
        'monto': monto,
        'fecha': fechaInicial,
        'descripcion': descripcion,
        'categoria': categoria,
        'metodoPago': metodoPago,
        'usuarioId': _userId,
        'fechaCreacion': FieldValue.serverTimestamp(),
        // Solo 3 campos extra para automatización
        'tieneRepeticion': true,
        'frecuencia': FrecuenciaUtils.aString(frecuencia),
        'proximaCreacion': FrecuenciaUtils.calcularProximaFecha(fechaInicial, frecuencia),
      };

      if (cuentaAsociada != null) {
        datos['cuentaAsociada'] = cuentaAsociada;
      }

      await _ingresosRef().add(datos);
      return null;
    } catch (e) {
      return 'Error al crear ingreso: $e';
    }
  }

  /// Verifica y crea los ingresos que ya deben existir
  Future<int> procesarIngresosAutomaticos() async {
    try {
      if (_userId == null) return 0;

      final ahora = DateTime.now();
      int ingresosCreados = 0;

      // Buscar ingresos que tienen repetición programada
      final query = await _ingresosRef()
          .where('tieneRepeticion', isEqualTo: true)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final proximaCreacion = (data['proximaCreacion'] as Timestamp).toDate();

        // Si ya es tiempo de crear el siguiente
        if (_yaEsTiempo(ahora, proximaCreacion)) {
          await _crearSiguienteIngreso(doc.id, data);
          ingresosCreados++;
        }
      }

      return ingresosCreados;
    } catch (e) {
      print('Error procesando ingresos automáticos: $e');
      return 0;
    }
  }

  /// Crea el siguiente ingreso y actualiza la fecha
  Future<void> _crearSiguienteIngreso(String docId, Map<String, dynamic> data) async {
    final frecuencia = FrecuenciaUtils.desdeString(data['frecuencia'])!;
    final fechaActual = (data['proximaCreacion'] as Timestamp).toDate();
    
    // Crear nuevo ingreso (copia del original)
    final nuevoIngreso = {
      'monto': data['monto'],
      'fecha': fechaActual,
      'descripcion': data['descripcion'],
      'categoria': data['categoria'],
      'metodoPago': data['metodoPago'],
      'usuarioId': data['usuarioId'],
      'fechaCreacion': FieldValue.serverTimestamp(),
      // Sin campos de repetición - es un ingreso normal
    };

    if (data.containsKey('cuentaAsociada')) {
      nuevoIngreso['cuentaAsociada'] = data['cuentaAsociada'];
    }

    // Crear el nuevo ingreso
    await _ingresosRef().add(nuevoIngreso);

    // Actualizar la próxima fecha en el original
    final siguienteFecha = FrecuenciaUtils.calcularProximaFecha(fechaActual, frecuencia);
    await _ingresosRef().doc(docId).update({
      'proximaCreacion': siguienteFecha,
    });
  }

  bool _yaEsTiempo(DateTime ahora, DateTime proximaFecha) {
    return ahora.year > proximaFecha.year ||
        (ahora.year == proximaFecha.year && ahora.month > proximaFecha.month) ||
        (ahora.year == proximaFecha.year && 
         ahora.month == proximaFecha.month && 
         ahora.day >= proximaFecha.day);
  }

  /// Crea un solo ingreso normal (sin frecuencia)
  Future<String?> crearIngresoNormal({
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';

      final datos = {
        'monto': monto,
        'fecha': fecha,
        'descripcion': descripcion,
        'categoria': categoria,
        'metodoPago': metodoPago,
        'usuarioId': _userId,
        'fechaCreacion': FieldValue.serverTimestamp(),
      };

      if (cuentaAsociada != null) {
        datos['cuentaAsociada'] = cuentaAsociada;
      }

      await _ingresosRef().add(datos);
      return null;
    } catch (e) {
      return 'Error al crear ingreso: $e';
    }
  }

  /// Actualiza un ingreso y maneja los cambios de frecuencia
  Future<String?> actualizarIngresoConFrecuencia({
    required String ingresoId,
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    required TipoFrecuencia frecuenciaActual,
    required TipoFrecuencia nuevaFrecuencia,
    String? cuentaAsociada,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';

      final datos = <String, dynamic>{
        'monto': monto,
        'fecha': fecha,
        'descripcion': descripcion,
        'categoria': categoria,
        'metodoPago': metodoPago,
      };

      if (cuentaAsociada != null) {
        datos['cuentaAsociada'] = cuentaAsociada;
      } else {
        datos['cuentaAsociada'] = FieldValue.delete();
      }

      // Manejar cambios de frecuencia
      if (frecuenciaActual != nuevaFrecuencia) {
        if (nuevaFrecuencia == TipoFrecuencia.ninguna) {
          // Quitar frecuencia - eliminar campos de repetición
          datos['tieneRepeticion'] = FieldValue.delete();
          datos['frecuencia'] = FieldValue.delete();
          datos['proximaCreacion'] = FieldValue.delete();
        } else {
          // Agregar o cambiar frecuencia
          datos['tieneRepeticion'] = true;
          datos['frecuencia'] = FrecuenciaUtils.aString(nuevaFrecuencia);
          datos['proximaCreacion'] = FrecuenciaUtils.calcularProximaFecha(fecha, nuevaFrecuencia);
        }
      } else if (nuevaFrecuencia != TipoFrecuencia.ninguna) {
        // Mantener frecuencia pero actualizar próxima fecha si cambió la fecha base
        datos['proximaCreacion'] = FrecuenciaUtils.calcularProximaFecha(fecha, nuevaFrecuencia);
      }

      await _ingresosRef().doc(ingresoId).update(datos);
      return null;
    } catch (e) {
      return 'Error al actualizar ingreso: $e';
    }
  }
}