
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeudasServicio {
	final FirebaseFirestore _db = FirebaseFirestore.instance;
	final FirebaseAuth _auth = FirebaseAuth.instance;
	static const String _coleccionDeudas = 'deudas';

	String? get _userId => _auth.currentUser?.uid;

	/// Referencia a la subcolección de deudas del usuario
	CollectionReference<Map<String, dynamic>> _deudasRef() {
		if (_userId == null) {
			return _db.collection('usuarios/__no_user__/$_coleccionDeudas');
		}
		return _db.collection('usuarios').doc(_userId).collection(_coleccionDeudas);
	}

	/// Obtiene todas las deudas del usuario actual
	Future<List<Map<String, dynamic>>> obtenerDeudas() async {
		if (_userId == null) return [];
		final snapshot = await _deudasRef().get();
		return snapshot.docs.map((doc) {
			final data = doc.data();
			data['id'] = doc.id;
			return data;
		}).toList();
	}

	/// Crea una nueva deuda
	Future<void> crearDeuda(Map<String, dynamic> deuda) async {
		if (_userId == null) return;
		await _deudasRef().add(deuda);
	}

	/// Edita una deuda existente
	Future<void> editarDeuda(String deudaId, Map<String, dynamic> datosActualizados) async {
		await _deudasRef().doc(deudaId).update(datosActualizados);
	}

	/// Elimina una deuda
	Future<void> eliminarDeuda(String deudaId) async {
		await _deudasRef().doc(deudaId).delete();
	}
}
