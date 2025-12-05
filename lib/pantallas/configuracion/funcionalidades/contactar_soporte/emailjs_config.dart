/// Configuración para EmailJS
/// 
/// Para configurar EmailJS:
/// 1. Ve a https://www.emailjs.com/
/// 2. Crea una cuenta gratuita
/// 3. Configura un servicio de email (Gmail, Outlook, etc.)
/// 4. Crea una plantilla de email
/// 5. Obtén tu Public Key, Service ID y Template ID
class EmailJSConfig {
  // TODO: Reemplazar con tus valores reales de EmailJS
  // Estos son valores de ejemplo, debes configurar tu cuenta en emailjs.com
  
  /// Public Key de tu cuenta EmailJS
  static const String publicKey = 'X8Rvd-a8q2xTgs1pf';
  
   /// Service ID del servicio de email configurado
   static const String serviceId = 'service_yov5e2o';
  
  /// Template ID de la plantilla de email
  static const String templateId = 'template_tp0poln';
  
  /// Email de destino para soporte
  static const String emailDestino = 'walletfloww@gmail.com';
  
  /// Nombre de la aplicación
  static const String appName = 'Wallet Flow';
  
  /// Verificar si EmailJS está configurado
  static bool get isConfigured {
    return publicKey != 'YOUR_EMAILJS_PUBLIC_KEY' &&
           serviceId != 'YOUR_EMAILJS_SERVICE_ID' &&
           templateId != 'YOUR_EMAILJS_TEMPLATE_ID';
  }
}

/// Instrucciones para configurar EmailJS
class EmailJSInstrucciones {
  static const String configuracion = '''
CONFIGURACIÓN DE EMAILJS PARA WALLET FLOW

1. Crear cuenta en EmailJS:
   - Ve a https://www.emailjs.com/
   - Regístrate con tu email
   - Verifica tu cuenta

2. Configurar servicio de email:
   - En el dashboard, ve a "Email Services"
   - Añade un nuevo servicio (Gmail recomendado)
   - Sigue las instrucciones para conectar tu email
   - Anota el Service ID

3. Crear plantilla de email:
   - Ve a "Email Templates"
   - Crea nueva plantilla
   - Usa estas variables en la plantilla:
     * {{from_name}} - Nombre del usuario
     * {{from_email}} - Email del usuario
     * {{subject}} - Asunto del mensaje
     * {{category}} - Categoría del soporte
     * {{message}} - Mensaje completo
     * {{user_info}} - Información adicional del usuario
   - Anota el Template ID

4. Obtener Public Key:
   - Ve a "Account" > "General"
   - Copia tu Public Key

5. Actualizar configuración:
   - Reemplaza los valores en emailjs_config.dart
   - Compilar y probar la aplicación

EJEMPLO DE PLANTILLA:
Subject: [Soporte {{app_name}}] {{subject}}

Hola,

Has recibido un nuevo mensaje de soporte desde {{app_name}}:

Nombre: {{from_name}}
Email: {{from_email}}
Categoría: {{category}}
Asunto: {{subject}}

Mensaje:
{{message}}

Información adicional:
{{user_info}}

Saludos,
Sistema de Soporte {{app_name}}
''';
}