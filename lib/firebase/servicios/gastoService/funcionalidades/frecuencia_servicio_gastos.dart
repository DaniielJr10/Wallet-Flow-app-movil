/// SERVICIO SIMPLE DE FRECUENCIAS PARA GASTOS
/// Sistema sencillo: crea gasto + programa automáticamente los siguientes
/// Usa subcollecciones usuarios/{uid}/gastos como el resto del sistema
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../pantallas/gastos/funcionalidades/frecuencia.dart';

class FrecuenciaServicioGastos {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Referencia a la subcollección de gastos del usuario
  /// Estructura: usuarios/{uid}/gastos
  CollectionReference<Map<String, dynamic>> _gastosRef() {
    if (_userId == null) {
      return _firestore.collection('usuarios/__no_user__/gastos');
    }
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('gastos');
  }

  /// Crea un gasto que se repetirá automáticamente según la frecuencia
  Future<String?> crearGastoConFrecuencia({
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

      // Crear el gasto normal + campos de repetición
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

      await _gastosRef().add(datos);
      return null;
    } catch (e) {
      return 'Error al crear gasto: $e';
    }
  }

  /// Verifica y crea los gastos que ya deben existir
  Future<int> procesarGastosAutomaticos() async {
    try {
      if (_userId == null) return 0;

      final ahora = DateTime.now();
      int gastosCreados = 0;

      // Buscar gastos que tienen repetición programada
      final query = await _gastosRef()
          .where('tieneRepeticion', isEqualTo: true)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final proximaCreacion = (data['proximaCreacion'] as Timestamp).toDate();

        // Si ya es tiempo de crear el siguiente
        if (_yaEsTiempo(ahora, proximaCreacion)) {
          await _crearSiguienteGasto(doc.id, data);
          gastosCreados++;
        }
      }

      return gastosCreados;
    } catch (e) {
      print('Error procesando gastos automáticos: $e');
      return 0;
    }
  }

  /// Crea el siguiente gasto y actualiza la fecha
  Future<void> _crearSiguienteGasto(String docId, Map<String, dynamic> data) async {
    final frecuencia = FrecuenciaUtils.desdeString(data['frecuencia'])!;
    final fechaActual = (data['proximaCreacion'] as Timestamp).toDate();
    
    // Crear nuevo gasto (copia del original)
    final nuevoGasto = {
      'monto': data['monto'],
      'fecha': fechaActual,
      'descripcion': data['descripcion'],
      'categoria': data['categoria'],
      'metodoPago': data['metodoPago'],
      'usuarioId': data['usuarioId'],
      'fechaCreacion': FieldValue.serverTimestamp(),
      // Sin campos de repetición - es un gasto normal
    };

    if (data.containsKey('cuentaAsociada')) {
      nuevoGasto['cuentaAsociada'] = data['cuentaAsociada'];
    }

    // Crear el nuevo gasto
    await _gastosRef().add(nuevoGasto);

    // Actualizar la próxima fecha en el original
    final siguienteFecha = FrecuenciaUtils.calcularProximaFecha(fechaActual, frecuencia);
    await _gastosRef().doc(docId).update({
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

  /// Crea un solo gasto normal (sin frecuencia)
  Future<String?> crearGastoNormal({
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

      await _gastosRef().add(datos);
      return null;
    } catch (e) {
      return 'Error al crear gasto: $e';
    }
  }

  /// Actualiza un gasto y maneja los cambios de frecuencia
  Future<String?> actualizarGastoConFrecuencia({
    required String gastoId,
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

      await _gastosRef().doc(gastoId).update(datos);
      return null;
    } catch (e) {
      return 'Error al actualizar gasto: $e';
    }
  }
}
