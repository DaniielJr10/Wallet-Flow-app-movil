/// SERVICIO SIMPLE DE FRECUENCIAS PARA DEUDAS
/// Sistema sencillo: crea deuda + programa automáticamente las siguientes
/// Usa subcollecciones usuarios/{uid}/deudas como el resto del sistema
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../pantallas/ingresos/funcionalidades/frecuencia.dart';

class FrecuenciaServicioDeudas {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Referencia a la subcollección de deudas del usuario
  /// Estructura: usuarios/{uid}/deudas
  CollectionReference<Map<String, dynamic>> _deudasRef() {
    if (_userId == null) {
      return _firestore.collection('usuarios/__no_user__/deudas');
    }
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('deudas');
  }

  /// Crea una deuda que se repetirá automáticamente según la frecuencia
  Future<String?> crearDeudaConFrecuencia({
    required String titulo,
    required String tipo,
    required double monto,
    required DateTime fechaVencimiento,
    required String acreedor,
    required TipoFrecuencia frecuencia,
    bool tieneRecordatorio = false,
    DateTime? fechaRecordatorio,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (titulo.trim().isEmpty) return 'El título es requerido';

      await _firestore.runTransaction((transaction) async {
        final deudaRef = _deudasRef().doc();

        final deudaData = {
          'titulo': titulo.trim(),
          'tipo': tipo,
          'montoOriginal': monto,
          'montoPendiente': monto,
          'tasaInteres': 0.0,
          'fechaVencimiento': fechaVencimiento,
          if (tieneRecordatorio && fechaRecordatorio != null) 'recordatorio': fechaRecordatorio,
          'estado': 'Pendiente',
          'fechaCreacion': DateTime.now(),
          'acreedor': acreedor.trim(),
          'numeroCuenta': '',
          'historialPagos': [],
          // Campos de repetición
          'tieneRepeticion': true,
          'frecuencia': FrecuenciaUtils.aString(frecuencia),
          'proximaCreacion': FrecuenciaUtils.calcularProximaFecha(fechaVencimiento, frecuencia),
        };

        transaction.set(deudaRef, deudaData);
      });

      return null;
    } catch (e) {
      return 'Error al crear deuda: $e';
    }
  }

  /// Verifica y crea las deudas que ya deben existir
  Future<int> procesarDeudasAutomaticas() async {
    try {
      if (_userId == null) return 0;

      final ahora = DateTime.now();
      int deudasCreadas = 0;

      final query = await _deudasRef()
          .where('tieneRepeticion', isEqualTo: true)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final proximaCreacion = (data['proximaCreacion'] as Timestamp).toDate();

        if (_yaEsTiempo(ahora, proximaCreacion)) {
          await _crearSiguienteDeuda(doc.id, data);
          deudasCreadas++;
        }
      }

      return deudasCreadas;
    } catch (e) {
      print('Error procesando deudas automáticas: $e');
      return 0;
    }
  }

  /// Crea la siguiente deuda y actualiza la fecha
  Future<void> _crearSiguienteDeuda(String docId, Map<String, dynamic> data) async {
    final frecuencia = FrecuenciaUtils.desdeString(data['frecuencia'])!;
    final fechaActual = (data['proximaCreacion'] as Timestamp).toDate();
    final monto = (data['montoOriginal'] as num).toDouble();

    await _firestore.runTransaction((transaction) async {
      final deudaRef = _deudasRef().doc();
      final nuevaDeuda = {
        'titulo': data['titulo'],
        'tipo': data['tipo'],
        'montoOriginal': monto,
        'montoPendiente': monto,
        'tasaInteres': data['tasaInteres'] ?? 0.0,
        'fechaVencimiento': fechaActual,
        if (data.containsKey('recordatorio') && data['recordatorio'] != null) 
          'recordatorio': data['recordatorio'],
        'estado': 'Pendiente',
        'fechaCreacion': DateTime.now(),
        'acreedor': data['acreedor'],
        'numeroCuenta': data['numeroCuenta'] ?? '',
        'historialPagos': [],
      };

      transaction.set(deudaRef, nuevaDeuda);

      final siguienteFecha = FrecuenciaUtils.calcularProximaFecha(fechaActual, frecuencia);
      final deudaOriginalRef = _deudasRef().doc(docId);
      transaction.update(deudaOriginalRef, {
        'proximaCreacion': siguienteFecha,
      });
    });
  }

  bool _yaEsTiempo(DateTime ahora, DateTime proximaFecha) {
    return ahora.year > proximaFecha.year ||
        (ahora.year == proximaFecha.year && ahora.month > proximaFecha.month) ||
        (ahora.year == proximaFecha.year && 
         ahora.month == proximaFecha.month && 
         ahora.day >= proximaFecha.day);
  }

  /// Crea una sola deuda normal (sin frecuencia)
  Future<String?> crearDeudaNormal({
    required String titulo,
    required String tipo,
    required double monto,
    required DateTime fechaVencimiento,
    required String acreedor,
    bool tieneRecordatorio = false,
    DateTime? fechaRecordatorio,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (titulo.trim().isEmpty) return 'El título es requerido';

      await _firestore.runTransaction((transaction) async {
        final deudaRef = _deudasRef().doc();

        final deudaData = {
          'titulo': titulo.trim(),
          'tipo': tipo,
          'montoOriginal': monto,
          'montoPendiente': monto,
          'tasaInteres': 0.0,
          'fechaVencimiento': fechaVencimiento,
          if (tieneRecordatorio && fechaRecordatorio != null) 'recordatorio': fechaRecordatorio,
          'estado': 'Pendiente',
          'fechaCreacion': DateTime.now(),
          'acreedor': acreedor.trim(),
          'numeroCuenta': '',
          'historialPagos': [],
        };

        transaction.set(deudaRef, deudaData);
      });

      return null;
    } catch (e) {
      return 'Error al crear deuda: $e';
    }
  }

  /// Actualiza una deuda y maneja los cambios de frecuencia
  Future<String?> actualizarDeudaConFrecuencia({
    required String deudaId,
    required String titulo,
    required String tipo,
    required double monto,
    required DateTime fechaVencimiento,
    required String acreedor,
    required TipoFrecuencia frecuenciaActual,
    required TipoFrecuencia nuevaFrecuencia,
    bool tieneRecordatorio = false,
    DateTime? fechaRecordatorio,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (titulo.trim().isEmpty) return 'El título es requerido';

      await _firestore.runTransaction((transaction) async {
        final deudaRef = _deudasRef().doc(deudaId);
        final deudaDoc = await transaction.get(deudaRef);

        if (!deudaDoc.exists) throw Exception('La deuda no existe');

        final nuevosdatos = <String, dynamic>{
          'titulo': titulo.trim(),
          'tipo': tipo,
          'montoOriginal': monto,
          'montoPendiente': monto,
          'fechaVencimiento': fechaVencimiento,
          'acreedor': acreedor.trim(),
          if (tieneRecordatorio && fechaRecordatorio != null) 
            'recordatorio': fechaRecordatorio
          else if (!tieneRecordatorio)
            'recordatorio': FieldValue.delete(),
          'fechaModificacion': FieldValue.serverTimestamp(),
        };

        // Manejar cambios de frecuencia
        if (frecuenciaActual != nuevaFrecuencia) {
          if (nuevaFrecuencia == TipoFrecuencia.ninguna) {
            nuevosdatos['tieneRepeticion'] = FieldValue.delete();
            nuevosdatos['frecuencia'] = FieldValue.delete();
            nuevosdatos['proximaCreacion'] = FieldValue.delete();
          } else {
            nuevosdatos['tieneRepeticion'] = true;
            nuevosdatos['frecuencia'] = FrecuenciaUtils.aString(nuevaFrecuencia);
            nuevosdatos['proximaCreacion'] = FrecuenciaUtils.calcularProximaFecha(fechaVencimiento, nuevaFrecuencia);
          }
        } else if (nuevaFrecuencia != TipoFrecuencia.ninguna) {
          nuevosdatos['proximaCreacion'] = FrecuenciaUtils.calcularProximaFecha(fechaVencimiento, nuevaFrecuencia);
        }

        transaction.update(deudaRef, nuevosdatos);
      });

      return null;
    } catch (e) {
      return 'Error al actualizar deuda: $e';
    }
  }
}
