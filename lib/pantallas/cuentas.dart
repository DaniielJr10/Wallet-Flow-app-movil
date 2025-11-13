import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaCuentas extends StatefulWidget {
  const PantallaCuentas({super.key});

  @override
  State<PantallaCuentas> createState() => _PantallaCuentasState();
}

class _PantallaCuentasState extends State<PantallaCuentas> with TickerProviderStateMixin {

  Widget _buildBarraBusqueda() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _busquedaController,
                onChanged: (value) {
                  setState(() {
                    if (_modoFiltro == 'buscar') {
                      _busquedaNumero = value;
                    } else {
                      _busquedaCuenta = value;
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: _modoFiltro == 'buscar' ? 'Buscar por número de cuenta...' : 'Buscar cuenta...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                  suffixIcon: _busquedaController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _busquedaController.clear();
                            setState(() {
                              if (_modoFiltro == 'buscar') {
                                _busquedaNumero = '';
                              } else {
                                _busquedaCuenta = '';
                              }
                            });
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Color(0xFF007bff).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.filter_alt_rounded, color: Color(0xFF007bff)),
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF007bff), width: 0.7),
              ),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, color: Color(0xFF007bff), size: 18),
                      const SizedBox(width: 8),
                      Text('Modo de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF007bff))),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: 'ordenar_desc',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.trending_down_rounded, color: _modoFiltro == 'ordenar' && _ordenSaldo == 'desc' ? Color(0xFF007bff) : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text('Mayor saldo', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      if (_modoFiltro == 'ordenar' && _ordenSaldo == 'desc') ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, color: Color(0xFF007bff), size: 18),
                      ]
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ordenar_asc',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: _modoFiltro == 'ordenar' && _ordenSaldo == 'asc' ? Color(0xFF007bff) : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text('Menor saldo', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      if (_modoFiltro == 'ordenar' && _ordenSaldo == 'asc') ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, color: Color(0xFF007bff), size: 18),
                      ]
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'buscar',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: _modoFiltro == 'buscar' ? Color(0xFF007bff) : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text('Buscar por número de cuenta', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      if (_modoFiltro == 'buscar') ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, color: Color(0xFF007bff), size: 18),
                      ]
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                setState(() {
                  if (value == 'ordenar_desc') {
                    _modoFiltro = 'ordenar';
                    _ordenSaldo = 'desc';
                  } else if (value == 'ordenar_asc') {
                    _modoFiltro = 'ordenar';
                    _ordenSaldo = 'asc';
                  } else if (value == 'buscar') {
                    _modoFiltro = 'buscar';
                  }
                  _busquedaController.text = '';
                  _busquedaCuenta = '';
                  _busquedaNumero = '';
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  // ...otros métodos y variables...

  final TextEditingController _busquedaController = TextEditingController();

  String _modoFiltro = 'ordenar';
  String _ordenSaldo = 'desc';
  String _busquedaCuenta = '';
  String _busquedaNumero = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
         title: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Row(
               mainAxisSize: MainAxisSize.min,
               children: const [
                 Icon(
                   Icons.account_balance_rounded,
                   color: Color(0xFF007bff),
                   size: 28,
                 ),
                 SizedBox(width: 8),
                 Text(
                   'CUENTAS',
                   style: TextStyle(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                     color: Color(0xFF007bff),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 2),
             Text(
               'Administra y visualiza todas tus cuentas bancarias',
               style: TextStyle(
                 fontSize: 14,
                 color: Colors.grey,
                 fontWeight: FontWeight.w500,
               ),
             ),
           ],
         ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _construirResumenFinanciero(),
              const SizedBox(height: 24),
              _buildBarraBusqueda(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cuentas registradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: _mostrarDialogoAgregarCuenta,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007bff),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Nueva cuenta',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _construirListaCuentas(),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _construirResumenFinanciero() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('cuentas')
          .where('usuarioId', isEqualTo: _auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 120);
        }

        double totalBalance = 0;
        int totalCuentas = snapshot.data!.docs.length;

        for (var doc in snapshot.data!.docs) {
          totalBalance += (doc.data() as Map<String, dynamic>)['saldo'] ?? 0.0;
        }

        return Container(
          margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF007bff),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007bff).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Balance Total',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalCuentas cuenta${totalCuentas != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${_formatearMoneda(totalBalance)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirListaCuentas() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('cuentas')
          .where('usuarioId', isEqualTo: _auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          );
        }

        if (snapshot.hasError) {
          return _construirEstadoError();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _construirEstadoVacio();
        }

        // Filtrado por búsqueda
        var docs = snapshot.data!.docs.where((doc) {
          final cuenta = doc.data() as Map<String, dynamic>;
          bool match = true;
          if (_busquedaCuenta.isNotEmpty) {
            final nombre = (cuenta['nombre'] ?? '').toString().toLowerCase();
            final banco = (cuenta['banco'] ?? '').toString().toLowerCase();
            final numero = (cuenta['numeroCuenta'] ?? '').toString().toLowerCase();
            match = nombre.contains(_busquedaCuenta.toLowerCase()) ||
                    banco.contains(_busquedaCuenta.toLowerCase()) ||
                    numero.contains(_busquedaCuenta.toLowerCase());
          }
          if (_modoFiltro == 'buscar' && _busquedaNumero.isNotEmpty) {
            final numero = (cuenta['numeroCuenta'] ?? '').toString().toLowerCase();
            match = match && numero.contains(_busquedaNumero.toLowerCase());
          }
          return match;
        }).toList();

        if (_modoFiltro == 'ordenar') {
          docs.sort((a, b) {
            final saldoA = (a.data() as Map<String, dynamic>)['saldo'] ?? 0.0;
            final saldoB = (b.data() as Map<String, dynamic>)['saldo'] ?? 0.0;
            if (_ordenSaldo == 'desc') {
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
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No se encontraron cuentas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta con otro término de búsqueda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final cuenta = doc.data() as Map<String, dynamic>;
            return _construirTarjetaCuenta(doc.id, cuenta, index);
          },
        );
      },
    );
  }

  Widget _construirTarjetaCuenta(String id, Map<String, dynamic> cuenta, int index) {
    final tipoCuenta = cuenta['tipo'] ?? 'ahorros';
    final nombreCuenta = cuenta['nombre'] ?? 'Cuenta sin nombre';
    final saldo = (cuenta['saldo'] ?? 0.0).toDouble();
    final numeroCuenta = cuenta['numeroCuenta'] ?? '****';
    final banco = cuenta['banco'] ?? 'Banco';

    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        top: index == 0 ? 8 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetallesCuenta(id, cuenta),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _obtenerColorTipoCuenta(tipoCuenta).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _obtenerIconoTipoCuenta(tipoCuenta),
                        color: _obtenerColorTipoCuenta(tipoCuenta),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombreCuenta,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              '$banco • $numeroCuenta',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _manejarAccionCuenta(value, id, cuenta),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_formatearMoneda(saldo)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D29),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _obtenerColorTipoCuenta(tipoCuenta).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _obtenerNombreTipoCuenta(tipoCuenta),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _obtenerColorTipoCuenta(tipoCuenta),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes cuentas registradas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D29),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera cuenta para comenzar\na gestionar tus finanzas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _mostrarDialogoAgregarCuenta,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Cuenta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirEstadoError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar las cuentas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta nuevamente más tarde',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAgregarCuenta() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DialogoAgregarCuenta(
        onCuentaAgregada: () {
          setState(() {});
        },
      ),
    );
  }

  void _mostrarDetallesCuenta(String id, Map<String, dynamic> cuenta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetallesCuenta(
        cuentaId: id,
        cuenta: cuenta,
      ),
    );
  }

  void _manejarAccionCuenta(String accion, String id, Map<String, dynamic> cuenta) {
    switch (accion) {
      case 'editar':
        _mostrarDialogoEditarCuenta(id, cuenta);
        break;
      case 'eliminar':
        _confirmarEliminarCuenta(id, cuenta['nombre'] ?? 'esta cuenta');
        break;
    }
  }

  void _mostrarDialogoEditarCuenta(String id, Map<String, dynamic> cuenta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DialogoAgregarCuenta(
        cuentaId: id,
        cuentaExistente: cuenta,
        onCuentaAgregada: () {
          setState(() {});
        },
      ),
    );
  }

  Future<void> _confirmarEliminarCuenta(String id, String nombre) async {
    final bool? confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Eliminar cuenta'),
        content: Text('¿Estás seguro de que deseas eliminar $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        await _firestore.collection('cuentas').doc(id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$nombre eliminada correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la cuenta'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Color _obtenerColorTipoCuenta(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return const Color(0xFF10B981);
      case 'corriente':
        return const Color(0xFF3B82F6);
      case 'credito':
        return const Color(0xFF8B5CF6);
      case 'inversion':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _obtenerIconoTipoCuenta(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return Icons.savings_outlined;
      case 'corriente':
        return Icons.account_balance_outlined;
      case 'credito':
        return Icons.credit_card_outlined;
      case 'inversion':
        return Icons.trending_up_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _obtenerNombreTipoCuenta(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return 'Ahorros';
      case 'corriente':
        return 'Corriente';
      case 'credito':
        return 'Crédito';
      case 'inversion':
        return 'Inversión';
      default:
        return 'Cuenta';
    }
  }

  String _formatearMoneda(double cantidad) {
    if (cantidad >= 1000000) {
      return '${(cantidad / 1000000).toStringAsFixed(1)}M';
    } else if (cantidad >= 1000) {
      return '${(cantidad / 1000).toStringAsFixed(1)}K';
    } else {
      return cantidad.toStringAsFixed(0);
    }
  }
}

class _DialogoAgregarCuenta extends StatefulWidget {
  final VoidCallback onCuentaAgregada;
  final String? cuentaId;
  final Map<String, dynamic>? cuentaExistente;

  const _DialogoAgregarCuenta({
    required this.onCuentaAgregada,
    this.cuentaId,
    this.cuentaExistente,
  });

  @override
  State<_DialogoAgregarCuenta> createState() => _DialogoAgregarCuentaState();
}

class _DialogoAgregarCuentaState extends State<_DialogoAgregarCuenta> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _bancoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _saldoController = TextEditingController();
  
  String _tipoSeleccionado = 'ahorros';
  bool _cargando = false;

  final List<Map<String, dynamic>> _tiposCuenta = [
    {
      'valor': 'ahorros',
      'nombre': 'Cuenta de Ahorros',
      'icono': Icons.savings_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'valor': 'corriente',
      'nombre': 'Cuenta Corriente',
      'icono': Icons.account_balance_outlined,
      'color': Color(0xFF3B82F6),
    },
    {
      'valor': 'credito',
      'nombre': 'Tarjeta de Crédito',
      'icono': Icons.credit_card_outlined,
      'color': Color(0xFF8B5CF6),
    },
    {
      'valor': 'inversion',
      'nombre': 'Cuenta de Inversión',
      'icono': Icons.trending_up_outlined,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cuentaExistente != null) {
      _cargarDatosCuenta();
    }
  }

  void _cargarDatosCuenta() {
    final cuenta = widget.cuentaExistente!;
    _nombreController.text = cuenta['nombre'] ?? '';
    _bancoController.text = cuenta['banco'] ?? '';
    _numeroController.text = cuenta['numeroCuenta'] ?? '';
    _saldoController.text = (cuenta['saldo'] ?? 0.0).toString();
    _tipoSeleccionado = cuenta['tipo'] ?? 'ahorros';
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.cuentaExistente != null;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    esEdicion ? 'Editar Cuenta' : 'Agregar Cuenta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          const Divider(),
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de cuenta
                    const Text(
                      'Tipo de cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _tiposCuenta.length,
                      itemBuilder: (context, index) {
                        final tipo = _tiposCuenta[index];
                        final seleccionado = _tipoSeleccionado == tipo['valor'];
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _tipoSeleccionado = tipo['valor'];
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: seleccionado 
                                ? tipo['color'].withOpacity(0.1)
                                : Colors.grey[50],
                              border: Border.all(
                                color: seleccionado 
                                  ? tipo['color']
                                  : Colors.grey[300]!,
                                width: seleccionado ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  tipo['icono'],
                                  color: seleccionado 
                                    ? tipo['color']
                                    : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tipo['nombre'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: seleccionado 
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                      color: seleccionado 
                                        ? tipo['color']
                                        : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Nombre de la cuenta
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la cuenta',
                        hintText: 'Ej: Mi cuenta principal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Banco
                    TextFormField(
                      controller: _bancoController,
                      decoration: InputDecoration(
                        labelText: 'Banco',
                        hintText: 'Ej: Banco Nacional',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.account_balance),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El banco es requerido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Número de cuenta
                    TextFormField(
                      controller: _numeroController,
                      decoration: InputDecoration(
                        labelText: 'Número de cuenta',
                        hintText: 'Últimos 4 dígitos',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de cuenta es requerido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Saldo
                    TextFormField(
                      controller: _saldoController,
                      decoration: InputDecoration(
                        labelText: 'Saldo inicial',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El saldo es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un saldo válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Botón guardar
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cargando ? null : _guardarCuenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      esEdicion ? 'Actualizar Cuenta' : 'Crear Cuenta',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarCuenta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
    });

    try {
      final datosCuenta = {
        'nombre': _nombreController.text.trim(),
        'banco': _bancoController.text.trim(),
        'numeroCuenta': _numeroController.text.trim(),
        'saldo': double.parse(_saldoController.text),
        'tipo': _tipoSeleccionado,
        'usuarioId': FirebaseAuth.instance.currentUser?.uid,
        'fechaModificacion': FieldValue.serverTimestamp(),
      };

      if (widget.cuentaId != null) {
        // Actualizar cuenta existente
        await FirebaseFirestore.instance
            .collection('cuentas')
            .doc(widget.cuentaId)
            .update(datosCuenta);
      } else {
        // Crear nueva cuenta
        datosCuenta['fechaCreacion'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('cuentas')
            .add(datosCuenta);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onCuentaAgregada();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cuentaId != null 
                ? 'Cuenta actualizada correctamente'
                : 'Cuenta creada correctamente'
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _bancoController.dispose();
    _numeroController.dispose();
    _saldoController.dispose();
    super.dispose();
  }
}

class _DetallesCuenta extends StatelessWidget {
  final String cuentaId;
  final Map<String, dynamic> cuenta;

  const _DetallesCuenta({
    required this.cuentaId,
    required this.cuenta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const Expanded(
                  child: Text(
                    'Detalles de la Cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          const Divider(),
          
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica
                  _construirItemDetalle(
                    'Nombre',
                    cuenta['nombre'] ?? 'Sin nombre',
                    Icons.label_outline,
                  ),
                  _construirItemDetalle(
                    'Banco',
                    cuenta['banco'] ?? 'Sin banco',
                    Icons.account_balance,
                  ),
                  _construirItemDetalle(
                    'Número de cuenta',
                    '**** ${cuenta['numeroCuenta'] ?? '****'}',
                    Icons.credit_card,
                  ),
                  _construirItemDetalle(
                    'Tipo',
                    _obtenerNombreTipo(cuenta['tipo'] ?? 'ahorros'),
                    _obtenerIconoTipo(cuenta['tipo'] ?? 'ahorros'),
                  ),
                  _construirItemDetalle(
                    'Saldo actual',
                    '\$${(cuenta['saldo'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.attach_money,
                    destacado: true,
                  ),
                  
                  const Spacer(),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implementar transferencia
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Transferir'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar historial
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('Historial'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirItemDetalle(
    String titulo,
    String valor,
    IconData icono, {
    bool destacado = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: destacado 
                ? const Color(0xFF6366F1).withOpacity(0.1)
                : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icono,
              color: destacado 
                ? const Color(0xFF6366F1)
                : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: destacado ? 18 : 16,
                    fontWeight: destacado ? FontWeight.bold : FontWeight.w600,
                    color: destacado 
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF1A1D29),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerNombreTipo(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return 'Cuenta de Ahorros';
      case 'corriente':
        return 'Cuenta Corriente';
      case 'credito':
        return 'Tarjeta de Crédito';
      case 'inversion':
        return 'Cuenta de Inversión';
      default:
        return 'Cuenta';
    }
  }

  IconData _obtenerIconoTipo(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return Icons.savings_outlined;
      case 'corriente':
        return Icons.account_balance_outlined;
      case 'credito':
        return Icons.credit_card_outlined;
      case 'inversion':
        return Icons.trending_up_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}