import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/servicios/cuentas_servicio.dart';
import '../../utilidades/formato_numeros.dart';

class PantallaCuentas extends StatefulWidget {
  const PantallaCuentas({super.key});

  // const Divider(), // Eliminado para quitar la línea gris debajo del fondo azul
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
                            setState(() {
                              _busquedaController.clear();
                              _busquedaCuenta = '';
                              _busquedaNumero = '';
                            });
                          },
                          icon: Icon(
                            Icons.clear,
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

  final CuentasServicio _cuentasServicio = CuentasServicio();
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

    // Intentar migrar datos existentes desde la colección raíz a
    // usuarios/{uid}/cuentas. Es idempotente y solo afectará si hay datos
    // antiguos. No bloquea la UI.
    // Ignorar el resultado; sirve como paso de transición.
    _cuentasServicio.migrarCuentasDesdeColeccionRaiz();
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
        toolbarHeight: 120,
         title: Padding(
           padding: const EdgeInsets.only(top: 20),
           child: Column(
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
      stream: _cuentasServicio.obtenerCuentas(),
      builder: (context, snapshot) {
        // Manejo de estado de conexión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFF007bff),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        // Si hay error, mostrar resumen con valores por defecto
        if (snapshot.hasError) {
          print('Error en resumen financiero: ${snapshot.error}');
        }

        // Procesar datos (incluso si hay error, mostrar lo que se pueda)
        double totalBalance = 0;
        int totalCuentas = 0;
        
        if (snapshot.hasData && snapshot.data != null) {
          totalCuentas = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null && data['saldo'] != null) {
              totalBalance += (data['saldo'] as num).toDouble();
            }
          }
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
      stream: _cuentasServicio.obtenerCuentas(),
      builder: (context, snapshot) {
        print('🔍 Estado del snapshot: ${snapshot.connectionState}');
        print('🔍 Tiene datos: ${snapshot.hasData}');
        print('🔍 Tiene error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('🚨 Error específico: ${snapshot.error}');
          print('🚨 Stack trace: ${snapshot.stackTrace}');
        }
        if (snapshot.hasData) {
          print('📊 Número de documentos: ${snapshot.data!.docs.length}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007bff)),
            ),
          );
        }

        // Manejo de errores más específico
        if (snapshot.hasError) {
          print('Error en lista de cuentas: ${snapshot.error}');
          // Si hay datos a pesar del error, intentamos mostrarlos
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _construirEstadoError();
          }
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _construirEstadoVacio();
        }

        // Filtrado por búsqueda
        var docs = snapshot.data!.docs.where((doc) {
          final cuenta = doc.data() as Map<String, dynamic>;
          bool match = true;
          if (_busquedaCuenta.isNotEmpty) {
            final banco = (cuenta['banco'] ?? '').toString().toLowerCase();
            final numero = (cuenta['numeroCuenta'] ?? '').toString().toLowerCase();
            match = banco.contains(_busquedaCuenta.toLowerCase()) ||
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
                            banco,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              numeroCuenta,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40),
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
              color: const Color(0xFF007bff).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: Color(0xFF007bff),
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
          // Botón 'Agregar Cuenta' eliminado según solicitud
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
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _DialogoAgregarCuenta(
          onCuentaAgregada: () {
            setState(() {});
          },
        ),
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
        onEditar: () => _mostrarDialogoEditarCuenta(id, cuenta),
        onEliminar: () => _confirmarEliminarCuenta(id, 'esta cuenta'),
      ),
    );
  }

  void _mostrarDialogoEditarCuenta(String id, Map<String, dynamic> cuenta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _DialogoAgregarCuenta(
          cuentaId: id,
          cuentaExistente: cuenta,
          onCuentaAgregada: () {
            setState(() {});
          },
        ),
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
        final error = await _cuentasServicio.eliminarCuentaPermanente(id);
        if (mounted) {
          if (error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$nombre eliminada correctamente'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
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
      default:
        return 'Cuenta';
    }
  }

  String _formatearMoneda(double cantidad) {
    return FormatoNumeros.formatearParaMostrar(cantidad);
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
      'color': Color(0xFF007bff),
    },
    {
      'valor': 'corriente',
      'nombre': 'Cuenta Corriente',
      'icono': Icons.account_balance_outlined,
      'color': Color(0xFF007bff),
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
    _bancoController.text = cuenta['banco'] ?? '';
    _numeroController.text = cuenta['numeroCuenta'] ?? '';
    _saldoController.text = FormatoNumeros.formatearNumero(cuenta['saldo'] ?? 0.0);
    _tipoSeleccionado = cuenta['tipo'] ?? 'ahorros';
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.cuentaExistente != null;
    final maxHeight = MediaQuery.of(context).size.height * 0.77;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = maxHeight - keyboardHeight;
    
    return Container(
      height: keyboardHeight > 0 ? availableHeight : maxHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header y handle bar con fondo azul
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF007bff),
              // Sin borderRadius para el header azul
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        esEdicion ? 'Editar Cuenta' : 'Agregar Cuenta',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          ),
          
          // const Divider(), // Eliminado para quitar la línea gris entre el header azul y el formulario
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de cuenta
                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          color: Color(0xFF007bff),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Tipo de cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
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
                    
                    const SizedBox(height: 16),
                    
                    // Banco
                    TextFormField(
                      controller: _bancoController,
                      decoration: InputDecoration(
                        labelText: 'Banco',
                        hintText: 'Ej: Banco Nacional',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF007bff), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.account_balance, color: Color(0xFF007bff)),
                        labelStyle: const TextStyle(color: Colors.black87),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El banco es requerido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Número de cuenta
                    TextFormField(
                      controller: _numeroController,
                      decoration: InputDecoration(
                        labelText: 'Número de cuenta',
                        hintText: 'Número completo de la cuenta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF007bff), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF007bff)),
                        labelStyle: const TextStyle(color: Colors.black87),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de cuenta es requerido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Saldo
                    TextFormField(
                      controller: _saldoController,
                      decoration: InputDecoration(
                        labelText: 'Saldo inicial',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF007bff), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF007bff)),
                        labelStyle: const TextStyle(color: Colors.black87),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [
                        FormateadorNumeros(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El saldo es requerido';
                        }
                        final saldo = FormatoNumeros.convertirANumero(value);
                        if (saldo == null) {
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007bff).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _cargando ? null : _guardarCuenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007bff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          esEdicion ? Icons.update : Icons.save,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          esEdicion ? 'Actualizar Cuenta' : 'Crear Cuenta',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
      final cuentasServicio = CuentasServicio();
      String? error;
      
      if (widget.cuentaId != null) {
        // Actualizar cuenta existente
        error = await cuentasServicio.actualizarCuenta(
          cuentaId: widget.cuentaId!,
          banco: _bancoController.text.trim(),
          numeroCuenta: _numeroController.text.trim(),
          tipo: _tipoSeleccionado,
          saldo: FormatoNumeros.convertirANumero(_saldoController.text) ?? 0,
        );
      } else {
        // Crear nueva cuenta
        error = await cuentasServicio.crearCuenta(
          banco: _bancoController.text.trim(),
          numeroCuenta: _numeroController.text.trim(),
          tipo: _tipoSeleccionado,
          saldo: FormatoNumeros.convertirANumero(_saldoController.text) ?? 0,
        );
      }

      if (mounted) {
        if (error == null) {
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
    _bancoController.dispose();
    _numeroController.dispose();
    _saldoController.dispose();
    super.dispose();
  }
}

class _DetallesCuenta extends StatelessWidget {
  final String cuentaId;
  final Map<String, dynamic> cuenta;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _DetallesCuenta({
    required this.cuentaId,
    required this.cuenta,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header azul
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF007bff),
                  Color(0xFF0056b3),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _obtenerIconoTipoLocal(cuenta['tipo'] ?? 'ahorros'),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles de la Cuenta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        cuenta['banco'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido de los detalles
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saldo principal destacado
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF007bff).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFF007bff), width: 2),
                      ),
                      child: Text(
                        '\$${FormatoNumeros.formatearParaMostrar(cuenta['saldo'] ?? 0.0)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF007bff),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tarjetas de detalles
                  _buildDetalleItem('Banco', cuenta['banco'] ?? 'Sin banco', Icons.account_balance),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Número de cuenta', cuenta['numeroCuenta'] ?? '****', Icons.credit_card),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Tipo', _obtenerNombreTipoLocal(cuenta['tipo'] ?? 'ahorros'), _obtenerIconoTipoLocal(cuenta['tipo'] ?? 'ahorros')),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Botones de acción
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEliminar,
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un item de detalle con icono, título y valor (estilo tarjeta)
  Widget _buildDetalleItem(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF007bff).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              color: Color(0xFF007bff),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
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
                ? const Color(0xFF007bff).withOpacity(0.1)
                : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icono,
              color: destacado 
                ? const Color(0xFF007bff)
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
                      ? const Color(0xFF007bff)
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

  String _obtenerNombreTipoLocal(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return 'Cuenta de Ahorros';
      case 'corriente':
        return 'Cuenta Corriente';
      default:
        return 'Cuenta';
    }
  }

  IconData _obtenerIconoTipoLocal(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return Icons.savings_outlined;
      case 'corriente':
        return Icons.account_balance_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}