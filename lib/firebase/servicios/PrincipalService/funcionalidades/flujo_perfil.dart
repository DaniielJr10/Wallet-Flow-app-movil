// 5. Stream en tiempo real de estadísticas de usuario
// Escucha cambios en ingresos, gastos y ahorros para generar métricas de perfil.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_principal.dart';

mixin FlujoPerfil on ReferenciasPrincipal {
  
  /// Emite estadísticas de perfil en tiempo real combinando snapshots
  Stream<Map<String, dynamic>> obtenerEstadisticasPerfilStream() {
    if (userId == null) {
      return Stream.value({
        'transaccionesTotales': 0,
        'gastoPromedio': 0.0,
        'ahorroTotal': 0.0,
        'diasActivo': 0,
        'categoriaMasUsada': 'General',
      });
    }

    final ingresosRef = firestore.collection('usuarios').doc(userId).collection('ingresos');
    final gastosRef = firestore.collection('usuarios').doc(userId).collection('gastos');
    final ahorrosRef = firestore.collection('usuarios').doc(userId).collection('ahorros');

    StreamController<Map<String, dynamic>> controller = StreamController.broadcast();

    QuerySnapshot? lastIngresos;
    QuerySnapshot? lastGastos;
    QuerySnapshot? lastAhorros;

    void emitirEstadisticas() {
      try {
        if (controller.isClosed) return;

        // Transacciones totales: ingresos + gastos
        final transacciones = (lastIngresos?.docs.length ?? 0) + (lastGastos?.docs.length ?? 0);

        // Gasto promedio
        double sumaGastos = 0.0;
        int countGastos = 0;
        if (lastGastos != null) {
          for (var d in lastGastos!.docs) {
            final data = d.data() as Map<String, dynamic>;
            final monto = (data['monto'] ?? 0) is num ? (data['monto'] as num).toDouble() : 0.0;
            sumaGastos += monto;
            countGastos++;
          }
        }
        final gastoPromedio = countGastos > 0 ? (sumaGastos / countGastos) : 0.0;

        // Ahorro total
        double ahorroTotal = 0.0;
        if (lastAhorros != null) {
          for (var d in lastAhorros!.docs) {
            final data = d.data() as Map<String, dynamic>;
            final montoActual = (data['montoActual'] ?? 0) is num ? (data['montoActual'] as num).toDouble() : 0.0;
            ahorroTotal += montoActual;
          }
        }

        // Dias activo: desde la fecha más antigua entre ingresos/gastos/ahorros
        DateTime? fechaMin;
        List<QuerySnapshot?> listas = [lastIngresos, lastGastos, lastAhorros];
        for (var snap in listas) {
          if (snap == null) continue;
          for (var doc in snap.docs) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime? fecha;
            if (data['fechaCreacion'] is Timestamp) {
              fecha = (data['fechaCreacion'] as Timestamp).toDate();
            } else if (data['fecha'] is Timestamp) {
              fecha = (data['fecha'] as Timestamp).toDate();
            } else if (data['fechaCreacion'] is DateTime) {
              fecha = data['fechaCreacion'] as DateTime;
            }
            
            if (fecha != null) {
              if (fechaMin == null || fecha.isBefore(fechaMin)) fechaMin = fecha;
            }
          }
        }
        final diasActivo = fechaMin != null ? DateTime.now().difference(fechaMin).inDays : 0;

        // Categoria mas usada (ingresos + gastos)
        final Map<String, int> categoriasCount = {};
        void contarCategoriasDeSnapshot(QuerySnapshot? snap) {
          if (snap == null) return;
          for (var doc in snap.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat = (data['categoria'] ?? 'General').toString();
            categoriasCount[cat] = (categoriasCount[cat] ?? 0) + 1;
          }
        }

        contarCategoriasDeSnapshot(lastIngresos);
        contarCategoriasDeSnapshot(lastGastos);

        String categoriaMasUsada = 'General';
        int maxCount = 0;
        categoriasCount.forEach((k, v) {
          if (v > maxCount) {
            maxCount = v;
            categoriaMasUsada = k;
          }
        });

        controller.add({
          'transaccionesTotales': transacciones,
          'gastoPromedio': gastoPromedio,
          'ahorroTotal': ahorroTotal,
          'diasActivo': diasActivo,
          'categoriaMasUsada': categoriaMasUsada,
        });
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    StreamSubscription? ingresosSub;
    StreamSubscription? gastosSub;
    StreamSubscription? ahorrosSub;

    ingresosSub = ingresosRef.snapshots().listen((snap) {
      lastIngresos = snap;
      emitirEstadisticas();
    }, onError: (e) => !controller.isClosed ? controller.addError(e) : null);

    gastosSub = gastosRef.snapshots().listen((snap) {
      lastGastos = snap;
      emitirEstadisticas();
    }, onError: (e) => !controller.isClosed ? controller.addError(e) : null);

    ahorrosSub = ahorrosRef.snapshots().listen((snap) {
      lastAhorros = snap;
      emitirEstadisticas();
    }, onError: (e) => !controller.isClosed ? controller.addError(e) : null);

    controller.onCancel = () async {
      await ingresosSub?.cancel();
      await gastosSub?.cancel();
      await ahorrosSub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }
}