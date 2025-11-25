import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/cuentas_servicio.dart';
import 'tarjeta_cuenta.dart';
import 'lista_estados.dart';

class ListaCuentasBuilder extends StatelessWidget {
  final CuentasServicio cuentasServicio;
  final String busquedaCuenta;
  final String busquedaNumero;
  final String modoFiltro;
  final String ordenSaldo;
  final Function(String id, Map<String, dynamic> cuenta) onCuentaTap;

  const ListaCuentasBuilder({
    super.key,
    required this.cuentasServicio,
    required this.busquedaCuenta,
    required this.busquedaNumero,
    required this.modoFiltro,
    required this.ordenSaldo,
    required this.onCuentaTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: cuentasServicio.obtenerCuentas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007bff)),
            ),
          );
        }

        if (snapshot.hasError) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EstadoCuentasError();
          }
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EstadoCuentasVacio();
        }

        // Lógica de filtrado
        var docs = snapshot.data!.docs.where((doc) {
          final cuenta = doc.data() as Map<String, dynamic>;
          bool match = true;
          
          if (busquedaCuenta.isNotEmpty) {
            final banco = (cuenta['banco'] ?? '').toString().toLowerCase();
            final numero = (cuenta['numeroCuenta'] ?? '').toString().toLowerCase();
            match = banco.contains(busquedaCuenta.toLowerCase()) ||
                    numero.contains(busquedaCuenta.toLowerCase());
          }
          
          if (modoFiltro == 'buscar' && busquedaNumero.isNotEmpty) {
            final numero = (cuenta['numeroCuenta'] ?? '').toString().toLowerCase();
            match = match && numero.contains(busquedaNumero.toLowerCase());
          }
          return match;
        }).toList();

        // Lógica de ordenamiento
        if (modoFiltro == 'ordenar') {
          docs.sort((a, b) {
            final saldoA = (a.data() as Map<String, dynamic>)['saldo'] ?? 0.0;
            final saldoB = (b.data() as Map<String, dynamic>)['saldo'] ?? 0.0;
            if (ordenSaldo == 'desc') {
              return saldoB.compareTo(saldoA);
            } else {
              return saldoA.compareTo(saldoB);
            }
          });
        } else {
          docs.sort((a, b) {
            final fechaA = (a.data() as Map<String, dynamic>)['fechaCreacion'] as Timestamp?;
            final fechaB = (b.data() as Map<String, dynamic>)['fechaCreacion'] as Timestamp?;
            if (fechaA == null && fechaB == null) return 0;
            if (fechaA == null) return 1;
            if (fechaB == null) return -1;
            return fechaB.compareTo(fechaA);
          });
        }

        if (docs.isEmpty) {
          return const EstadoSinResultadosBusqueda();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final cuenta = doc.data() as Map<String, dynamic>;
            return TarjetaCuenta(
              id: doc.id,
              cuenta: cuenta,
              index: index,
              onTap: () => onCuentaTap(doc.id, cuenta),
            );
          },
        );
      },
    );
  }
}