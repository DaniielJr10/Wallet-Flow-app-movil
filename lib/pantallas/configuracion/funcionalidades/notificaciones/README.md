# 🔔 Sistema de Configuración de Notificaciones

Esta carpeta contiene todos los archivos necesarios para que el usuario pueda configurar individualmente qué tipos de notificaciones desea recibir.

## 📁 Estructura de Archivos

### **Archivos Principales:**

1. **`pantalla_configuracion_notificaciones.dart`**
   - Pantalla principal donde el usuario configura sus notificaciones
   - Permite activar/desactivar cada tipo por separado
   - Interfaz amigable con switches organizados por categorías

2. **`preferencias_notificaciones.dart`**
   - Gestor de preferencias usando SharedPreferences
   - Guarda y recupera configuraciones del usuario
   - Maneja todos los tipos de notificaciones disponibles

3. **`gestor_notificaciones_configuracion.dart`**
   - Coordina los cambios con los sistemas de notificaciones reales
   - Aplica configuraciones a los servicios correspondientes
   - Gestiona la comunicación entre UI y servicios

4. **`widget_estado_notificaciones.dart`**
   - Widget que muestra el estado actual de las notificaciones
   - Visualización con barras de progreso y chips de estado
   - Resumen rápido de cuántas están activadas

5. **`index_notificaciones.dart`**
   - Archivo de índice para facilitar importaciones
   - Exporta todas las funcionalidades de la carpeta

## 🎯 **Tipos de Notificaciones Configurables:**

### **Generales** 🎛️
- **Switch maestro** que activa/desactiva todo el sistema
- Cuando se desactiva, todas las demás se desactivan automáticamente

### **Financieras** 💰
- **Ingresos**: Recordatorios de salarios, bonos, etc.
- **Gastos**: Recordatorios de pagos recurrentes y facturas  
- **Deudas**: Alertas de vencimiento (integrado con nuestro sistema)
- **Presupuesto**: Alertas cuando se exceden límites

### **Objetivos** 🎯
- **Ahorros**: Progreso y metas de ahorro
- **Metas**: Seguimiento de objetivos financieros

## 🚀 **Cómo Funciona:**

### 1. **Navegación desde Configuración:**
```dart
// En configuracion.dart, sección de notificaciones
ConfiguracionSecciones.buildSeccionNotificaciones(
  notificacionesActivas: _notificacionesActivas,
  onNotificacionesChanged: (value) => setState(() => _notificacionesActivas = value),
  guardarConfiguracion: _guardarConfiguracion,
  context: context, // Permite navegación
);
```

### 2. **Usuario hace clic en "Configurar Notificaciones":**
- Se abre `PantallaConfiguracionNotificaciones`
- Muestra todos los tipos organizados por secciones
- Cada switch controla un tipo específico

### 3. **Cuando el usuario cambia un setting:**
```dart
await PreferenciasNotificaciones.guardarPreferencia(tipo, valor);
await _gestor.aplicarCambioNotificacion(tipo, valor);
```

### 4. **El gestor aplica el cambio:**
- **Ingresos/Gastos**: Se comunica con `NotificacionesServicio.instance`
- **Deudas**: Se comunica con `NotificacionesDeudas.limpiarSistema()`
- **Otros**: Prepara para futuros sistemas

## 📱 **Interfaz de Usuario:**

### **Pantalla Principal:**
- **Encabezado** explicativo con icono
- **Sección General**: Switch maestro
- **Sección Financiera**: Notificaciones de dinero
- **Sección Metas**: Notificaciones de objetivos
- **Botones de acción**: "Activar Todas" / "Desactivar Todas"

### **Características UI:**
- ✅ **Switches individuales** para cada tipo
- ✅ **Iconos descriptivos** para cada categoría  
- ✅ **Colores organizados** por sección
- ✅ **Confirmaciones** con SnackBars
- ✅ **Desactivación en cascada** (si generales = false)
- ✅ **Diálogo de ayuda** explicativo

## 🔧 **Integración con Sistemas Existentes:**

### **Sistema de Ingresos/Gastos:**
```dart
await NotificacionesServicio.instance.configurarNotificaciones(activa);
```

### **Sistema de Deudas:**
```dart
if (!activa) {
  await NotificacionesDeudas.limpiarSistema();
}
```

### **Sistemas Futuros:**
```dart
// Preparado para cuando se implementen
await _configurarNotificacionesAhorros(activa);
await _configurarNotificacionesPresupuesto(activa);
```

## 📊 **Persistencia de Datos:**

### **SharedPreferences Keys:**
- `notificaciones_generales`
- `notificaciones_ingresos`  
- `notificaciones_gastos`
- `notificaciones_deudas`
- `notificaciones_ahorros`
- `notificaciones_presupuesto`
- `notificaciones_metas`

### **Valores por Defecto:**
- **Todos los tipos**: `true` (activados por defecto)
- **Primer uso**: Se crean automáticamente al acceder

## 🎨 **Experiencia de Usuario:**

### **Flujo Típico:**
1. Usuario va a Configuración
2. Ve sección "Notificaciones" con switch general
3. Hace clic en "Configurar Notificaciones"
4. Se abre pantalla detallada
5. Activa/desactiva tipos específicos
6. Ve confirmaciones inmediatas
7. Cambios se aplican automáticamente

### **Casos Especiales:**
- **Desactivar Generales**: Pregunta de confirmación
- **Reactivar Generales**: Reactiva según preferencias individuales  
- **Error al guardar**: Muestra mensaje de error
- **Ayuda**: Explicación de cada tipo de notificación

## 🔮 **Extensibilidad:**

### **Para agregar nuevo tipo:**
1. Agregar key en `PreferenciasNotificaciones`
2. Agregar método en `GestorNotificacionesConfiguracion`
3. Agregar switch en `PantallaConfiguracionNotificaciones`
4. Implementar lógica en el sistema correspondiente

### **Ejemplo - Agregar "Inversiones":**
```dart
// En PreferenciasNotificaciones
static const String _keyNotificacionesInversiones = 'notificaciones_inversiones';

// En GestorNotificacionesConfiguracion
case 'inversiones':
  await _configurarNotificacionesInversiones(activa);
  break;

// En PantallaConfiguracionNotificaciones
_construirSwitchTile(
  tipo: 'inversiones',
  titulo: 'Alertas de Inversiones',
  subtitulo: 'Cambios en el portafolio',
  icono: Icons.trending_up,
  habilitado: _preferencias['generales'] ?? true,
),
```

## ✅ **Estado Actual:**

- ✅ **Completamente funcional**
- ✅ **Integrado con sistemas existentes**
- ✅ **UI amigable y intuitiva**
- ✅ **Persistencia de configuraciones**
- ✅ **Navegación desde configuración principal**
- ✅ **Preparado para extensiones futuras**

**¡El sistema está listo para usar!** 🎉
