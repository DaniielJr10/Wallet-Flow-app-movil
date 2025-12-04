/**
 * FUNCIONALIDAD: Exportación de datos - REFACTORIZADO
 * 
 * Este archivo ahora actúa como punto de entrada simplificado
 * para la funcionalidad de exportación. Todo el código ha sido
 * modularizado en servicios especializados para mayor mantenibilidad.
 * 
 * Nueva estructura:
 * - coordinador_exportacion.dart: Orquestador principal
 * - modelos/: Definiciones de datos
 * - servicios/: Lógica de negocio separada
 * - widgets/: Componentes de UI
 */

import 'package:flutter/material.dart';
import 'coordinador_exportacion.dart';

class ConfiguracionExportar {
  /// Muestra el modal de opciones de exportación
  /// 
  /// Esta es la función principal que debe ser llamada desde la UI
  static void mostrarOpcionesExportacion(BuildContext context) {
    CoordinadorExportacion.mostrarOpcionesExportacion(context);
  }

  /// Exporta directamente a PDF (función de conveniencia)
  static Future<void> exportarAPdf(BuildContext context) async {
    CoordinadorExportacion.mostrarOpcionesExportacion(context);
  }

  /// Exporta directamente a Excel (función de conveniencia)
  static Future<void> exportarAExcel(BuildContext context) async {
    CoordinadorExportacion.mostrarOpcionesExportacion(context);
  }
}

/*
=============================================================================
ARQUITECTURA REFACTORIZADA:

📁 exportar_pdf_excel/
├── 📄 configuracion_exportar.dart (este archivo - punto de entrada)
├── 📄 coordinador_exportacion.dart (orquestador principal)
├── 📁 modelos/
│   └── 📄 datos_exportacion.dart (estructuras de datos)
├── 📁 servicios/
│   ├── 📄 recopilador_datos.dart (obtención de datos de Firebase)
│   ├── 📄 exportador_pdf.dart (generación de PDFs)
│   ├── 📄 exportador_excel.dart (generación de Excel)
│   └── 📄 gestor_archivos.dart (manejo de archivos multiplataforma)
└── 📁 widgets/
    └── 📄 widgets_exportacion.dart (componentes de UI)

BENEFICIOS DE LA REFACTORIZACIÓN:
✅ Separación de responsabilidades
✅ Código más mantenible y testeable
✅ Reutilización de componentes
✅ Manejo de errores centralizado
✅ Interfaz más profesional
✅ Soporte mejorado para web y móvil
✅ Documentación clara y estructura modular

CÓMO USAR:
```dart
// Desde cualquier pantalla de configuración:
ConfiguracionExportar.mostrarOpcionesExportacion(context);
```
=============================================================================
*/