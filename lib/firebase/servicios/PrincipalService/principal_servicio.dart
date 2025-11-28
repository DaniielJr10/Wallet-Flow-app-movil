// 1. Archivo Principal - El que llaman las pantallas
// Servicio principal de agregación de datos para el dashboard.

import 'funcionalidades/referencias_principal.dart';
import 'funcionalidades/calculos_totales.dart';
import 'funcionalidades/flujo_resumen.dart';
import 'funcionalidades/flujo_perfil.dart';

/// Servicio principal que obtiene y calcula datos resumidos
/// para mostrar en la pantalla principal de Wallet Flow
/// 
/// Combina datos de Ingresos, Gastos, Cuentas, Ahorros y Deudas.
class PrincipalServicio extends ReferenciasPrincipal
    with
        CalculosTotales,
        FlujoResumen,
        FlujoPerfil {
  
  // La clase integra automáticamente:
  // - Futures de totales (obtenerTotalCuentas, obtenerTotalIngresos, etc.)
  // - Stream del Dashboard (obtenerResumenFinanciero)
  // - Stream del Perfil (obtenerEstadisticasPerfilStream)
}