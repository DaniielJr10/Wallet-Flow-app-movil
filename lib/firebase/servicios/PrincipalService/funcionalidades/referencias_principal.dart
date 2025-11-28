// 2. Conexión y Referencias
// Configuración base para el servicio Principal.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferenciasPrincipal {
  // === INSTANCIAS DE FIREBASE ===
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Obtiene el ID del usuario autenticado actual
  String? get userId => auth.currentUser?.uid;

  // No definimos colecciones específicas aquí porque este servicio 
  // accede a casi todas ('usuarios/{uid}/ingresos', 'gastos', etc.)
  // Las referencias se construirán dinámicamente en los métodos.
}