import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PantallaGastos extends StatefulWidget {
  const PantallaGastos({super.key});

  @override
  State<PantallaGastos> createState() => _PantallaGastosState();
}

class _PantallaGastosState extends State<PantallaGastos>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _notaController = TextEditingController();
  final _busquedaController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime? _fechaSeleccionada = DateTime.now();
  String _categoriaSeleccionada = 'alimentación';
  String _metodoPagoSeleccionado = 'efectivo';
  String _cuentaAsociada = 'ninguna';
  bool _esRecurrente = false;
  String _frecuenciaRecurrente = 'mensual';
  String _textoBusqueda = '';
  
  List<Map<String, dynamic>> _gastos = [];
  List<Map<String, dynamic>> _gastosFiltrados = [];

  final List<String> _categorias = [
    'alimentación',
    'transporte',
    'entretenimiento',
    'salud',
    'educación',
    'servicios',
    'compras',
    'viajes',
    'otro'
  ];

  final List<String> _metodosPago = [
    'efectivo',
    'transferencia',
    'cheque'
  ];

  final List<String> _cuentas = [
    'ninguna',
    'cuenta corriente',
    'cuenta ahorros'
  ];

  final List<String> _frecuencias = [
    'diario',
    'semanal',
    'mensual',
    'anual'
  ];

  /// Inicializa el estado del widget y configura las animaciones
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

    _animationController.forward();
    _cargarGastosDePrueba();
  }

  /// Libera los recursos utilizados por los controladores y animaciones
  @override
  void dispose() {
    _animationController.dispose();
    _montoController.dispose();
    _descripcionController.dispose();
    _notaController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  /// Carga datos de prueba para mostrar ejemplos de gastos
  void _cargarGastosDePrueba() {
    setState(() {
      _gastos = [
        {
          'id': '1',
          'monto': 45.20,
          'fecha': DateTime.now().subtract(const Duration(days: 1)),
          'descripcion': 'Supermercado',
          'categoria': 'alimentación',
          'metodoPago': 'efectivo',
          'cuentaAsociada': 'cuenta corriente',
          'nota': 'Compras semanales',
          'esRecurrente': false,
        },
        {
          'id': '2',
          'monto': 15.50,
          'fecha': DateTime.now().subtract(const Duration(days: 3)),
          'descripcion': 'Transporte público',
          'categoria': 'transporte',
          'metodoPago': 'efectivo',
          'cuentaAsociada': 'ninguna',
          'nota': '',
          'esRecurrente': true,
        },
      ];
      _gastosFiltrados = List.from(_gastos);
    });
  }

  /// Filtra los gastos basado en el texto de búsqueda
  void _filtrarGastos(String textoBusqueda) {
    setState(() {
      _textoBusqueda = textoBusqueda;
      if (textoBusqueda.isEmpty) {
        _gastosFiltrados = List.from(_gastos);
      } else {
        _gastosFiltrados = _gastos.where((gasto) {
          return gasto['descripcion']
                  .toString()
                  .toLowerCase()
                  .contains(textoBusqueda.toLowerCase()) ||
              gasto['categoria']
                  .toString()
                  .toLowerCase()
                  .contains(textoBusqueda.toLowerCase()) ||
              gasto['metodoPago']
                  .toString()
                  .toLowerCase()
                  .contains(textoBusqueda.toLowerCase());
        }).toList();
      }
    });
  }

  /// Muestra el modal con el formulario para registrar un nuevo gasto
  void _mostrarFormularioGasto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFormularioModal(),
    );
  }

  /// Construye el modal que contiene el formulario de nuevo gasto
  Widget _buildFormularioModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade600,
                  Colors.red.shade700,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payment_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nuevo Gasto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCampoMonto(),
                    const SizedBox(height: 20),
                    _buildCampoDescripcion(),
                    const SizedBox(height: 20),
                    _buildSelectorFecha(),
                    const SizedBox(height: 20),
                    _buildSelectorCategoria(),
                    const SizedBox(height: 20),
                    _buildSelectorMetodoPago(),
                    const SizedBox(height: 20),
                    _buildSelectorCuentaAsociada(),
                    const SizedBox(height: 20),
                    _buildCampoNota(),
                    const SizedBox(height: 20),
                    _buildSwitchRecurrente(),
                    if (_esRecurrente) ...[
                      const SizedBox(height: 20),
                      _buildSelectorFrecuencia(),
                    ],
                    const SizedBox(height: 32),
                    _buildBotonesAccion(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el campo de entrada para el monto del gasto
  Widget _buildCampoMonto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el monto';
            }
            final monto = double.tryParse(value);
            if (monto == null || monto <= 0) {
              return 'Ingresa un monto válido mayor a 0';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// Construye el campo de entrada para la descripción del gasto
  Widget _buildCampoDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una descripción';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Ej: Supermercado, gasolina, cena...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// Construye el selector de fecha para el gasto
  Widget _buildSelectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _fechaSeleccionada != null
                      ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'
                      : 'Seleccionar fecha',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el dropdown para seleccionar la categoría del gasto
  Widget _buildSelectorCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categoriaSeleccionada,
              isExpanded: true,
              items: _categorias.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Row(
                    children: [
                      Icon(
                        _getIconoCategoria(categoria),
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        categoria.substring(0, 1).toUpperCase() + categoria.substring(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el dropdown para seleccionar el método de pago
  Widget _buildSelectorMetodoPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _metodoPagoSeleccionado,
              isExpanded: true,
              items: _metodosPago.map((metodo) {
                return DropdownMenuItem(
                  value: metodo,
                  child: Text(
                    metodo.substring(0, 1).toUpperCase() + metodo.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _metodoPagoSeleccionado = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el dropdown para seleccionar la cuenta asociada
  Widget _buildSelectorCuentaAsociada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuenta Asociada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _cuentaAsociada,
              isExpanded: true,
              items: _cuentas.map((cuenta) {
                return DropdownMenuItem(
                  value: cuenta,
                  child: Text(
                    cuenta.substring(0, 1).toUpperCase() + cuenta.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _cuentaAsociada = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el campo opcional para notas adicionales
  Widget _buildCampoNota() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nota (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notaController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Información adicional sobre el gasto...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// Construye el switch para marcar el gasto como recurrente
  Widget _buildSwitchRecurrente() {
    return Row(
      children: [
        Switch(
          value: _esRecurrente,
          onChanged: (value) {
            setState(() {
              _esRecurrente = value;
            });
          },
          activeColor: Colors.red.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gasto Recurrente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                'Marcar si este gasto se repite regularmente',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye el selector de frecuencia para gastos recurrentes
  Widget _buildSelectorFrecuencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frecuencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _frecuenciaRecurrente,
              isExpanded: true,
              items: _frecuencias.map((frecuencia) {
                return DropdownMenuItem(
                  value: frecuencia,
                  child: Text(
                    frecuencia.substring(0, 1).toUpperCase() + frecuencia.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _frecuenciaRecurrente = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Construye los botones de acción del formulario (Cancelar y Guardar)
  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              _limpiarFormulario();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _guardarGasto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye una barra de búsqueda moderna y profesional
  Widget _buildBarraBusqueda() {
    return Container(
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
        onChanged: _filtrarGastos,
        decoration: InputDecoration(
          hintText: 'Buscar gastos...',
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
          suffixIcon: _textoBusqueda.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _busquedaController.clear();
                    _filtrarGastos('');
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
              color: Colors.red.shade300,
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
    );
  }

  /// Construye la lista de gastos registrados o muestra estado vacío
  Widget _buildListaGastos() {
    final gastosAMostrar = _textoBusqueda.isEmpty ? _gastos : _gastosFiltrados;
    
    if (gastosAMostrar.isEmpty && _textoBusqueda.isNotEmpty) {
      return _buildEstadoSinResultados();
    }
    
    if (_gastos.isEmpty) {
      return _buildEstadoVacio();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gastosAMostrar.length,
      itemBuilder: (context, index) {
        final gasto = gastosAMostrar[index];
        return _buildTarjetaGastoSinCategoria(gasto, _gastos.indexOf(gasto));
      },
    );
  }

  /// Muestra un estado cuando no se encuentran resultados de búsqueda
  Widget _buildEstadoSinResultados() {
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
            'No se encontraron gastos',
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

  /// Construye una tarjeta individual para mostrar un gasto
  Widget _buildTarjetaGastoSinCategoria(Map<String, dynamic> gasto, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                gasto['descripcion'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            if (gasto['esRecurrente'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recurrente',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${gasto['metodoPago'].toString().substring(0, 1).toUpperCase()}${gasto['metodoPago'].toString().substring(1)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${gasto['fecha'].day}/${gasto['fecha'].month}/${gasto['fecha'].year}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            if (gasto['nota'] != null && gasto['nota'].isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                gasto['nota'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-${gasto['monto'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade600,
              ),
            ),
            IconButton(
              onPressed: () => _eliminarGasto(index),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(32, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un estado vacío cuando no hay gastos registrados
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.payment_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay gastos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primer gasto',
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

  /// Construye la tarjeta de resumen con el total de gastos
  Widget _buildResumenGastos() {
    final totalGastos = _gastos.fold<double>(
      0.0,
      (sum, gasto) => sum + gasto['monto'],
    );

    // Eliminado cálculo por categoría

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade600,
            Colors.red.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade600.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                'Total de Gastos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_gastos.length} registros',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${totalGastos.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Actualizado hace unos minutos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el gráfico de distribución de gastos por categoría
  Widget _buildGraficoGastos() {
    // Eliminado gráfico de distribución por categorías
    return const SizedBox.shrink();
  }

  /// Retorna el ícono correspondiente según la categoría del gasto
  IconData _getIconoCategoria(String categoria) {
    switch (categoria) {
      case 'alimentación':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'entretenimiento':
        return Icons.movie_rounded;
      case 'salud':
        return Icons.local_hospital_rounded;
      case 'educación':
        return Icons.school_rounded;
      case 'servicios':
        return Icons.build_rounded;
      case 'compras':
        return Icons.shopping_bag_rounded;
      case 'viajes':
        return Icons.flight_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  /// Retorna el color correspondiente según la categoría del gasto para el gráfico
  // ...existing code...

  /// Abre el selector de fecha para elegir cuándo se realizó el gasto
  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  /// Valida y guarda un nuevo gasto en la lista
  void _guardarGasto() {
    if (_formKey.currentState!.validate()) {
      final nuevoGasto = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'monto': double.parse(_montoController.text),
        'fecha': _fechaSeleccionada ?? DateTime.now(),
        'descripcion': _descripcionController.text,
        'categoria': _categoriaSeleccionada,
        'metodoPago': _metodoPagoSeleccionado,
        'cuentaAsociada': _cuentaAsociada,
        'nota': _notaController.text,
        'esRecurrente': _esRecurrente,
        'frecuencia': _esRecurrente ? _frecuenciaRecurrente : null,
      };

      setState(() {
        _gastos.insert(0, nuevoGasto);
        _filtrarGastos(_textoBusqueda); // Actualizar lista filtrada
      });

      Navigator.pop(context);
      _limpiarFormulario();
      _mostrarMensajeExito();
    }
  }

  /// Limpia todos los campos del formulario y restablece valores por defecto
  void _limpiarFormulario() {
    _montoController.clear();
    _descripcionController.clear();
    _notaController.clear();
    setState(() {
      _fechaSeleccionada = DateTime.now();
      _categoriaSeleccionada = 'alimentación';
      _metodoPagoSeleccionado = 'efectivo';
      _cuentaAsociada = 'ninguna';
      _esRecurrente = false;
      _frecuenciaRecurrente = 'mensual';
    });
  }

  /// Muestra un diálogo de confirmación para eliminar un gasto
  void _eliminarGasto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Estás seguro de que deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _gastos.removeAt(index);
                _filtrarGastos(_textoBusqueda); // Actualizar lista filtrada
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Gasto eliminado correctamente'),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje de éxito cuando se registra un gasto correctamente
  void _mostrarMensajeExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gasto registrado correctamente'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Gastos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF1F2937),
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumenGastos(),
              const SizedBox(height: 24),
              if (_gastos.isNotEmpty) ...[
                _buildGraficoGastos(),
                const SizedBox(height: 32),
              ],
              _buildBarraBusqueda(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historial de Gastos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _mostrarFormularioGasto,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Nuevo Gasto',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildListaGastos(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Eliminado FloatingActionButton
    );
  }
}
