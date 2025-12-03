/// SERVICIO DE INGRESOS RECURRENTES SÚPER SIMPLE
/// Solo agrega 3 campos a los ingresos normales para manejar recurrencia.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../pantallas/ingresos/funcionalidades/frecuencia.dart';

class RecurrenciaServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Crea un ingreso normal con solo 3 campos extra para recurrencia
  Future<String?> registrarIngresoRecurrente({
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

      // Crear ingreso normal con solo 3 campos extra
      final datos = {
        'monto': monto,
        'fecha': fechaInicial,
        'descripcion': descripcion,
        'categoria': categoria,
        'metodoPago': metodoPago,
        'usuarioId': _userId,
        'fechaCreacion': FieldValue.serverTimestamp(),
        // Solo 3 campos extra para recurrencia
        'esRecurrente': true,
        'frecuencia': FrecuenciaUtils.aString(frecuencia),
        'proximaFecha': FrecuenciaUtils.calcularProximaFecha(fechaInicial, frecuencia),
      };

      if (cuentaAsociada != null) {
        datos['cuentaAsociada'] = cuentaAsociada;
      }

      await _firestore.collection('ingresos').add(datos);
      return null;
    } catch (e) {
      return 'Error al crear ingreso recurrente: $e';
    }
  }

  /// Verifica y crea ingresos pendientes
  Future<int> generarIngresosPendientes() async {
    try {
      if (_userId == null) return 0;

      final ahora = DateTime.now();
      int ingresosGenerados = 0;

      // Buscar ingresos recurrentes que necesiten generar el siguiente
      final query = await _firestore
          .collection('ingresos')
          .where('usuarioId', isEqualTo: _userId)
          .where('esRecurrente', isEqualTo: true)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        
        // Si no tiene proximaFecha, continuar
        if (!data.containsKey('proximaFecha')) continue;
        
        final proximaFecha = (data['proximaFecha'] as Timestamp).toDate();
        final frecuencia = FrecuenciaUtils.desdeString(data['frecuencia']);

        if (frecuencia == null) continue;

        // Si ya es tiempo de crear el siguiente
        if (ahora.isAfter(proximaFecha) || _esMismaFecha(ahora, proximaFecha)) {
          // Crear nuevo ingreso normal (sin campos de recurrencia)
          await _crearIngresoNormal(
            monto: data['monto'],
            fecha: proximaFecha,
            descripcion: '${data['descripcion']} (automático)',
            categoria: data['categoria'],
            metodoPago: data['metodoPago'],
            cuentaAsociada: data['cuentaAsociada'],
          );

          // Actualizar solo la proximaFecha del ingreso original
          final nuevaProximaFecha = FrecuenciaUtils.calcularProximaFecha(proximaFecha, frecuencia);
          await _firestore.collection('ingresos').doc(doc.id).update({
            'proximaFecha': nuevaProximaFecha,
          });

          ingresosGenerados++;
        }
      }

      return ingresosGenerados;
    } catch (e) {
      print('Error generando ingresos pendientes: $e');
      return 0;
    }
  }

  /// Crea un ingreso completamente normal (sin campos de recurrencia)
  Future<void> _crearIngresoNormal({
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
  }) async {
    final datos = {
      'monto': monto,
      'fecha': fecha,
      'descripcion': descripcion,
      'categoria': categoria,
      'metodoPago': metodoPago,
      'usuarioId': _userId,
      'fechaCreacion': FieldValue.serverTimestamp(),
      // SIN campos de recurrencia - es ingreso normal
    };

    if (cuentaAsociada != null) {
      datos['cuentaAsociada'] = cuentaAsociada;
    }

    await _firestore.collection('ingresos').add(datos);
  }

  bool _esMismaFecha(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  /// Obtiene ingresos recurrentes (los que tienen esRecurrente = true)
  Stream<QuerySnapshot> obtenerIngresosRecurrentes() {
    if (_userId == null) return const Stream.empty();
    
    return _firestore
        .collection('ingresos')
        .where('usuarioId', isEqualTo: _userId)
        .where('esRecurrente', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots();
  }

  /// Desactiva la recurrencia (quita los campos de recurrencia)
  Future<String?> desactivarIngresoRecurrente(String id) async {
    try {
      await _firestore.collection('ingresos').doc(id).update({
        'esRecurrente': FieldValue.delete(),
        'frecuencia': FieldValue.delete(),
        'proximaFecha': FieldValue.delete(),
      });
      return null;
    } catch (e) {
      return 'Error al desactivar: $e';
    }
  }

  Future<DocumentSnapshot?> obtenerIngresoRecurrentePorId(String id) async {
    try {
      final doc = await _firestore.collection('ingresos').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['esRecurrente'] == true) return doc;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
