// 2. Conexión a Firebase y referencias a colecciones
// Configuración base para el servicio de Ahorros.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferenciasAhorros {
  // === INSTANCIAS DE FIREBASE ===
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // === CONSTANTES ===
  static const String coleccionAhorros = 'ahorros';

  /// Obtiene el ID del usuario autenticado actual
  String? get userId => auth.currentUser?.uid;

  /// Referencia a la subcolección de ahorros del usuario
  /// Estructura: usuarios/{uid}/ahorros/{metaId}
  CollectionReference<Map<String, dynamic>> ahorrosRef() {
    if (userId == null) {
      return firestore.collection('usuarios/__no_user__/$coleccionAhorros');
    }
    return firestore
        .collection('usuarios')
        .doc(userId)
        .collection(coleccionAhorros);
  }
}