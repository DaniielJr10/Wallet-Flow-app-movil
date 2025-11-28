// 2. Conexión a Firebase y referencias a colecciones
// Este archivo contiene las instancias base y la lógica de rutas de Firestore para Gastos.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferenciasGastos {
  // === INSTANCIAS DE FIREBASE ===
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // === CONSTANTES ===
  static const String coleccionGastos = 'gastos';

  /// Obtiene el ID del usuario autenticado actual
  String? get userId => auth.currentUser?.uid;

  /// Referencia a la subcolección de gastos del usuario autenticado
  /// Estructura: usuarios/{uid}/gastos
  CollectionReference<Map<String, dynamic>> gastosRef() {
    if (userId == null) {
      // Retorna referencia a colección ficticia si no hay usuario
      return firestore.collection('usuarios/__no_user__/$coleccionGastos');
    }
    return firestore
        .collection('usuarios')
        .doc(userId)
        .collection(coleccionGastos);
  }
}