// 2. Conexión a Firebase y referencias a colecciones
// Este archivo contiene las instancias base y la lógica de rutas de Firestore para Cuentas.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferenciasCuentas {
  // === INSTANCIAS DE FIREBASE ===
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // === CONSTANTES ===
  static const String coleccionCuentas = 'cuentas';

  /// Obtiene el ID del usuario autenticado actual
  String? get userId => auth.currentUser?.uid;

  /// Referencia a la subcolección de cuentas del usuario autenticado
  /// Estructura: usuarios/{uid}/cuentas
  CollectionReference<Map<String, dynamic>> cuentasRef() {
    if (userId == null) {
      // Retorna referencia segura para evitar errores de null,
      // aunque las validaciones previas deben manejar la autenticación.
      return firestore.collection('usuarios/__no_user__/$coleccionCuentas');
    }
    return firestore
        .collection('usuarios')
        .doc(userId)
        .collection(coleccionCuentas);
  }
}