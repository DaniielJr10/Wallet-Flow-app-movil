// 2. Conexión a Firebase y referencias a colecciones
// Este archivo contiene las instancias base y la lógica de rutas de Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferenciasBase {
  // === INSTANCIAS DE FIREBASE ===
  // Nota: Se quitaron los guiones bajos (_) para que sean accesibles desde los Mixins
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // === CONSTANTES ===
  static const String coleccionIngresos = 'ingresos';

  /// Obtiene el ID del usuario autenticado actual
  String? get userId => auth.currentUser?.uid;

  /// Referencia a la subcolección de ingresos del usuario
  /// Estructura: usuarios/{uid}/ingresos
  CollectionReference<Map<String, dynamic>> ingresosRef() {
    if (userId == null) {
      return firestore.collection('usuarios/__no_user__/$coleccionIngresos');
    }
    return firestore
        .collection('usuarios')
        .doc(userId)
        .collection(coleccionIngresos);
  }
}