/**
 * MODELO: Datos de exportación
 * 
 * Define las estructuras de datos utilizadas para organizar
 * la información antes de exportarla a PDF o Excel
 */

/// Clase que encapsula todos los datos necesarios para exportación
class DatosExportacion {
  final List<Map<String, dynamic>> ingresos;
  final List<Map<String, dynamic>> gastos;
  final List<Map<String, dynamic>> deudas;
  final List<Map<String, dynamic>> ahorros;
  final List<Map<String, dynamic>> cuentas;

  DatosExportacion({
    required this.ingresos,
    required this.gastos,
    required this.deudas,
    required this.ahorros,
    required this.cuentas,
  });

  /// Verifica si hay datos para exportar
  bool get tieneDatos =>
      ingresos.isNotEmpty ||
      gastos.isNotEmpty ||
      deudas.isNotEmpty ||
      ahorros.isNotEmpty ||
      cuentas.isNotEmpty;

  /// Obtiene un resumen de la cantidad de registros por categoría
  Map<String, int> get resumenDatos => {
        'Ingresos': ingresos.length,
        'Gastos': gastos.length,
        'Deudas': deudas.length,
        'Ahorros': ahorros.length,
        'Cuentas': cuentas.length,
      };
}

/// Configuración para personalizar la exportación
class ConfiguracionExportacion {
  final bool incluirIngresos;
  final bool incluirGastos;
  final bool incluirDeudas;
  final bool incluirAhorros;
  final bool incluirCuentas;
  final String nombreArchivo;
  final DateTime fechaGeneracion;

  ConfiguracionExportacion({
    this.incluirIngresos = true,
    this.incluirGastos = true,
    this.incluirDeudas = true,
    this.incluirAhorros = true,
    this.incluirCuentas = true,
    String? nombreArchivo,
    DateTime? fechaGeneracion,
  })  : nombreArchivo = nombreArchivo ?? 
            'walletflow_export_${DateTime.now().millisecondsSinceEpoch}',
        fechaGeneracion = fechaGeneracion ?? DateTime.now();
}