import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para gestionar deudas en Firebase
/// Estructura: usuarios/{uid}/deudas/{deudaId}
class DeudasServicio {
	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	final FirebaseAuth _auth = FirebaseAuth.instance;

	static const String _coleccionDeudas = 'deudas';

	String? get _userId => _auth.currentUser?.uid;

	/// Referencia a la subcolección de deudas del usuario
	CollectionReference<Map<String, dynamic>> _deudasRef() {
		if (_userId == null) {
			return _firestore.collection('usuarios/__no_user__/$_coleccionDeudas');
		}
		return _firestore
				.collection('usuarios')
				.doc(_userId)
				.collection(_coleccionDeudas);
	}

	/// === REGISTRAR NUEVA DEUDA ===
	Future<String?> registrarDeuda({
		required double monto,
		required DateTime fecha,
		required String descripcion,
		required String tipo, // tipo: personal, tarjeta, préstamo, etc.
		String? cuentaAsociada,
		String estado = 'pendiente', // pendiente, pagada, vencida
		DateTime? fechaVencimiento,
	}) async {
		try {
			if (_userId == null) return 'Usuario no autenticado';
			if (monto <= 0) return 'El monto debe ser mayor a 0';
			if (descripcion.trim().isEmpty) return 'La descripción es requerida';

			await _firestore.runTransaction((transaction) async {
				DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;
				if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
					final cuentaRef = _firestore
							.collection('usuarios')
							.doc(_userId)
							.collection('cuentas')
							.doc(cuentaAsociada);
					cuentaDoc = await transaction.get(cuentaRef);
					if (!cuentaDoc.exists) throw Exception('La cuenta asociada no existe');
				}

				final deudaRef = _deudasRef().doc();
				final deudaData = {
					'monto': monto,
					'fecha': Timestamp.fromDate(fecha),
					'descripcion': descripcion.trim(),
					'tipo': tipo,
					'cuentaAsociada': cuentaAsociada != 'ninguna' ? cuentaAsociada : null,
					'estado': estado,
					'fechaVencimiento': fechaVencimiento != null ? Timestamp.fromDate(fechaVencimiento) : null,
					'fechaCreacion': FieldValue.serverTimestamp(),
				};
				transaction.set(deudaRef, deudaData);

				// Si hay cuenta asociada, restar el monto del saldo
				if (cuentaDoc != null && cuentaDoc.exists) {
					final cuentaData = cuentaDoc.data()!;
					final saldoActual = (cuentaData['saldo'] as num?)?.toDouble() ?? 0.0;
					final nuevoSaldo = saldoActual - monto;
					transaction.update(cuentaDoc.reference, {
						'saldo': nuevoSaldo,
						'ultimaActualizacion': FieldValue.serverTimestamp(),
					});
					// Registrar movimiento en la cuenta
					final movimientoRef = cuentaDoc.reference.collection('movimientos').doc();
					transaction.set(movimientoRef, {
						'tipo': 'deuda',
						'monto': -monto,
						'descripcion': 'Deuda: $descripcion',
						'fecha': Timestamp.fromDate(fecha),
						'deudaId': deudaRef.id,
						'fechaCreacion': FieldValue.serverTimestamp(),
					});
				}
			});
			return null;
		} catch (e) {
			return 'Error al registrar la deuda: ${e.toString()}';
		}
	}

	/// === OBTENER DEUDAS DEL USUARIO ===
	Stream<List<Map<String, dynamic>>> obtenerDeudas() {
		if (_userId == null) return Stream.value([]);
		try {
			return _deudasRef().snapshots().map((snapshot) {
				final deudas = snapshot.docs.map((doc) {
					final data = doc.data();
					data['id'] = doc.id;
					if (data['fecha'] is Timestamp) {
						data['fecha'] = (data['fecha'] as Timestamp).toDate();
					}
					if (data['fechaVencimiento'] is Timestamp) {
						data['fechaVencimiento'] = (data['fechaVencimiento'] as Timestamp).toDate();
					}
					return data;
				}).toList();
				// Ordenar por fecha descendente
				deudas.sort((a, b) {
					final fechaA = a['fecha'] as DateTime;
					final fechaB = b['fecha'] as DateTime;
					return fechaB.compareTo(fechaA);
				});
				return deudas;
			});
		} catch (e) {
			return Stream.error(e);
		}
	}

	/// === OBTENER DEUDA POR ID ===
	Future<Map<String, dynamic>?> obtenerDeudaPorId(String deudaId) async {
		try {
			if (_userId == null) return null;
			final doc = await _deudasRef().doc(deudaId).get();
			if (!doc.exists) return null;
			final data = doc.data()!;
			data['id'] = doc.id;
			if (data['fecha'] is Timestamp) {
				data['fecha'] = (data['fecha'] as Timestamp).toDate();
			}
			if (data['fechaVencimiento'] is Timestamp) {
				data['fechaVencimiento'] = (data['fechaVencimiento'] as Timestamp).toDate();
			}
			return data;
		} catch (e) {
			return null;
		}
	}

	/// === ACTUALIZAR DEUDA ===
	Future<String?> actualizarDeuda({
		required String deudaId,
		required double monto,
		required DateTime fecha,
		required String descripcion,
		required String tipo,
		String? cuentaAsociada,
		String? estado,
		DateTime? fechaVencimiento,
	}) async {
		try {
			if (_userId == null) return 'Usuario no autenticado';
			if (monto <= 0) return 'El monto debe ser mayor a 0';
			if (descripcion.trim().isEmpty) return 'La descripción es requerida';

			await _firestore.runTransaction((transaction) async {
				// 1. Obtener la deuda actual
				final deudaRef = _deudasRef().doc(deudaId);
				final deudaDoc = await transaction.get(deudaRef);
				if (!deudaDoc.exists) throw Exception('La deuda no existe');
				final datosActuales = deudaDoc.data()!;
				final montoAnterior = (datosActuales['monto'] as num).toDouble();
				final cuentaAnterior = datosActuales['cuentaAsociada'] as String?;

				// 2. Leer cuenta anterior si existe
				DocumentSnapshot<Map<String, dynamic>>? cuentaAntDoc;
				if (cuentaAnterior != null && cuentaAnterior.isNotEmpty && cuentaAnterior != 'ninguna') {
					final cuentaAntRef = _firestore
							.collection('usuarios')
							.doc(_userId)
							.collection('cuentas')
							.doc(cuentaAnterior);
					cuentaAntDoc = await transaction.get(cuentaAntRef);
				}

				// 3. Leer nueva cuenta si existe y es diferente a la anterior
				DocumentSnapshot<Map<String, dynamic>>? cuentaNuevaDoc;
				if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
					final cuentaNuevaRef = _firestore
							.collection('usuarios')
							.doc(_userId)
							.collection('cuentas')
							.doc(cuentaAsociada);
					if (cuentaAsociada != cuentaAnterior) {
						cuentaNuevaDoc = await transaction.get(cuentaNuevaRef);
					} else {
						cuentaNuevaDoc = cuentaAntDoc;
					}
					if (cuentaNuevaDoc != null && !cuentaNuevaDoc.exists) {
						throw Exception('La cuenta asociada no existe');
					}
				}

				// 4. Actualizar los datos de la deuda
				final nuevosDatos = {
					'monto': monto,
					'fecha': Timestamp.fromDate(fecha),
					'descripcion': descripcion.trim(),
					'tipo': tipo,
					'cuentaAsociada': cuentaAsociada != 'ninguna' ? cuentaAsociada : null,
					'estado': estado ?? datosActuales['estado'],
					'fechaVencimiento': fechaVencimiento != null ? Timestamp.fromDate(fechaVencimiento) : null,
					'fechaModificacion': FieldValue.serverTimestamp(),
				};
				transaction.update(deudaRef, nuevosDatos);

				// 5. Manejar cambios en cuentas asociadas
				if (cuentaAnterior != cuentaAsociada) {
					// Sumar el monto anterior a la cuenta anterior
					if (cuentaAntDoc != null && cuentaAntDoc.exists) {
						final saldoAnterior = (cuentaAntDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
						transaction.update(cuentaAntDoc.reference, {
							'saldo': saldoAnterior + montoAnterior,
							'ultimaActualizacion': FieldValue.serverTimestamp(),
						});
					}
					// Restar el nuevo monto a la nueva cuenta
					if (cuentaNuevaDoc != null && cuentaNuevaDoc.exists) {
						final saldoNuevo = (cuentaNuevaDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
						transaction.update(cuentaNuevaDoc.reference, {
							'saldo': saldoNuevo - monto,
							'ultimaActualizacion': FieldValue.serverTimestamp(),
						});
						// Registrar movimiento en la nueva cuenta
						final movimientoRef = cuentaNuevaDoc.reference.collection('movimientos').doc();
						transaction.set(movimientoRef, {
							'tipo': 'deuda_actualizada',
							'monto': -monto,
							'descripcion': 'Deuda actualizada: $descripcion',
							'fecha': Timestamp.fromDate(fecha),
							'deudaId': deudaId,
							'fechaCreacion': FieldValue.serverTimestamp(),
						});
					}
				} else if (cuentaAsociada != null && cuentaAsociada != 'ninguna') {
					// Misma cuenta, solo actualizar la diferencia de monto
					if (cuentaAntDoc != null && cuentaAntDoc.exists) {
						final saldoActual = (cuentaAntDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
						final diferencia = montoAnterior - monto;
						transaction.update(cuentaAntDoc.reference, {
							'saldo': saldoActual + diferencia,
							'ultimaActualizacion': FieldValue.serverTimestamp(),
						});
					}
				}
			});
			return null;
		} catch (e) {
			return 'Error al actualizar la deuda: ${e.toString()}';
		}
	}

	/// === ELIMINAR DEUDA ===
	Future<String?> eliminarDeuda(String deudaId) async {
		try {
			if (_userId == null) return 'Usuario no autenticado';
			await _firestore.runTransaction((transaction) async {
				final deudaRef = _deudasRef().doc(deudaId);
				final deudaDoc = await transaction.get(deudaRef);
				if (!deudaDoc.exists) throw Exception('La deuda no existe');
				final deudaData = deudaDoc.data()!;
				final monto = (deudaData['monto'] as num).toDouble();
				final cuentaAsociada = deudaData['cuentaAsociada'] as String?;

				DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;
				if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
					final cuentaRef = _firestore
							.collection('usuarios')
							.doc(_userId)
							.collection('cuentas')
							.doc(cuentaAsociada);
					cuentaDoc = await transaction.get(cuentaRef);
				}

				// Si había cuenta asociada, sumar el monto al saldo
				if (cuentaDoc != null && cuentaDoc.exists) {
					final cuentaData = cuentaDoc.data()!;
					final saldoActual = (cuentaData['saldo'] as num?)?.toDouble() ?? 0.0;
					final nuevoSaldo = saldoActual + monto;
					transaction.update(cuentaDoc.reference, {
						'saldo': nuevoSaldo,
						'ultimaActualizacion': FieldValue.serverTimestamp(),
					});
					// Registrar movimiento de reversión
					final movimientoRef = cuentaDoc.reference.collection('movimientos').doc();
					transaction.set(movimientoRef, {
						'tipo': 'reversa_deuda',
						'monto': monto,
						'descripcion': 'Reversión de deuda eliminada',
						'deudaId': deudaId,
						'fecha': FieldValue.serverTimestamp(),
						'fechaCreacion': FieldValue.serverTimestamp(),
					});
				}
				transaction.delete(deudaRef);
			});
			return null;
		} catch (e) {
			return 'Error al eliminar la deuda: ${e.toString()}';
		}
	}

	/// === OBTENER DEUDAS COMO STREAM DE QUERYSNAPSHOT ===
	Stream<QuerySnapshot> obtenerDeudasStream() {
		if (_userId == null) return const Stream.empty();
		return _deudasRef().orderBy('fecha', descending: true).snapshots();
	}

	/// === OBTENER TOTAL DE DEUDAS ===
	Future<double> obtenerTotalDeudas({
		DateTime? fechaInicio,
		DateTime? fechaFin,
		String? tipo,
		String? estado,
	}) async {
		try {
			if (_userId == null) return 0.0;
			Query<Map<String, dynamic>> query = _deudasRef();
			if (fechaInicio != null) {
				query = query.where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio));
			}
			if (fechaFin != null) {
				query = query.where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));
			}
			if (tipo != null && tipo.isNotEmpty) {
				query = query.where('tipo', isEqualTo: tipo);
			}
			if (estado != null && estado.isNotEmpty) {
				query = query.where('estado', isEqualTo: estado);
			}
			final snapshot = await query.get();
			double total = 0.0;
			for (var doc in snapshot.docs) {
				final monto = (doc.data()['monto'] as num).toDouble();
				total += monto;
			}
			return total;
		} catch (e) {
			return 0.0;
		}
	}

	/// === OBTENER ESTADÍSTICAS DE DEUDAS ===
	Future<Map<String, dynamic>> obtenerEstadisticas({
		DateTime? fechaInicio,
		DateTime? fechaFin,
	}) async {
		try {
			if (_userId == null) return {'error': 'Usuario no autenticado'};
			fechaFin ??= DateTime.now();
			fechaInicio ??= DateTime(fechaFin.year, fechaFin.month - 1, fechaFin.day);
			final query = _deudasRef()
					.where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
					.where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));
			final snapshot = await query.get();
			double totalDeudas = 0;
			Map<String, double> deudasPorTipo = {};
			for (var doc in snapshot.docs) {
				final data = doc.data();
				final monto = (data['monto'] as num).toDouble();
				final tipo = data['tipo'] as String;
				totalDeudas += monto;
				deudasPorTipo[tipo] = (deudasPorTipo[tipo] ?? 0) + monto;
			}
			return {
				'totalDeudas': totalDeudas,
				'cantidadDeudas': snapshot.docs.length,
				'deudasPorTipo': deudasPorTipo,
						'promedioDeuda': snapshot.docs.isNotEmpty ? totalDeudas / snapshot.docs.length : 0,
					};
				} catch (e) {
					return {'error': e.toString()};
				}
			}
		}
