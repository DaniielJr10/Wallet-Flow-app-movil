// 2. Conexión a Firebase y referencias a colecciones
// Configuración base para el servicio de Deudas.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferenciasDeudas {
  // === INSTANCIAS DE FIREBASE ===
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // === CONSTANTES ===
  static const String coleccionDeudas = 'deudas';

  /// Obtiene el ID del usuario autenticado actual
  String? get userId => auth.currentUser?.uid;

  /// Referencia a la subcolección de deudas del usuario
  /// Estructura: usuarios/{uid}/deudas/{deudaId}
  CollectionReference<Map<String, dynamic>> deudasRef() {
    if (userId == null) {
      return firestore.collection('usuarios/__no_user__/$coleccionDeudas');
    }
    return firestore
        .collection('usuarios')
        .doc(userId)
        .collection(coleccionDeudas);
  }
}