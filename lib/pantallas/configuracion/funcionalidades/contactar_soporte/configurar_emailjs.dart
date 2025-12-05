import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'emailjs_config.dart';

/// Pantalla para configurar las credenciales de EmailJS
class ConfigurarEmailJSPantalla extends StatefulWidget {
  const ConfigurarEmailJSPantalla({super.key});

  @override
  State<ConfigurarEmailJSPantalla> createState() =>
      _ConfigurarEmailJSPantallaState();
}

class _ConfigurarEmailJSPantallaState extends State<ConfigurarEmailJSPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _publicKeyController = TextEditingController();
  final _serviceIdController = TextEditingController();
  final _templateIdController = TextEditingController();

  bool _mostrarConfiguracion = false;

  @override
  void dispose() {
    _publicKeyController.dispose();
    _serviceIdController.dispose();
    _templateIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar EmailJS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado actual
            _buildEstadoActual(),

            const SizedBox(height: 24),

            // Instrucciones
            _buildInstrucciones(),

            const SizedBox(height: 24),

            // Botón para mostrar/ocultar configuración
            _buildBotonConfiguracion(),

            if (_mostrarConfiguracion) ...[
              const SizedBox(height: 24),
              _buildFormularioConfiguracion(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoActual() {
    final isConfigured = EmailJSConfig.isConfigured;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.error,
                  color: isConfigured ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado de EmailJS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isConfigured
                  ? 'EmailJS está configurado y listo para enviar correos directamente desde la app.'
                  : 'EmailJS no está configurado. Los correos se enviarán usando la aplicación de correo del dispositivo.',
              style: TextStyle(
                color: isConfigured ? Colors.green[700] : Colors.orange[700],
              ),
            ),
            if (!isConfigured) ...[
              const SizedBox(height: 12),
              Text(
                'Configura EmailJS para enviar correos automáticamente sin salir de la app.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstrucciones() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Instrucciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Para configurar EmailJS sigue estos pasos:'),
            const SizedBox(height: 8),
            const Text('1. Ve a https://www.emailjs.com'),
            const Text('2. Crea una cuenta gratuita'),
            const Text('3. Configura un servicio de email (Gmail recomendado)'),
            const Text('4. Crea una plantilla de email'),
            const Text('5. Obtén tus credenciales y configurálas aquí'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarInstruccionesCompletas(),
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Ver instrucciones completas'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _abrirEmailJS(),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir EmailJS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonConfiguracion() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _mostrarConfiguracion = !_mostrarConfiguracion;
          });
        },
        icon: Icon(
          _mostrarConfiguracion
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
        ),
        label: Text(
          _mostrarConfiguracion
              ? 'Ocultar configuración'
              : 'Configurar credenciales',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFormularioConfiguracion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Credenciales de EmailJS',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Public Key
              TextFormField(
                controller: _publicKeyController,
                decoration: const InputDecoration(
                  labelText: 'Public Key',
                  hintText: 'Ej: user_abc123xyz',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa tu Public Key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service ID
              TextFormField(
                controller: _serviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Service ID',
                  hintText: 'Ej: service_abc123',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa tu Service ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Template ID
              TextFormField(
                controller: _templateIdController,
                decoration: const InputDecoration(
                  labelText: 'Template ID',
                  hintText: 'Ej: template_abc123',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa tu Template ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _limpiarFormulario,
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardarConfiguracion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Nota de seguridad
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nota importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Esta configuración se guardará temporalmente en la aplicación. '
                      'Para una implementación de producción, considera guardar estas '
                      'credenciales de forma segura.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarInstruccionesCompletas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instrucciones completas'),
        content: const SingleChildScrollView(
          child: Text(EmailJSInstrucciones.configuracion),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(text: EmailJSInstrucciones.configuracion),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Instrucciones copiadas al portapapeles'),
                ),
              );
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  void _abrirEmailJS() {
    // TODO: Implementar apertura de URL a emailjs.com
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abre tu navegador y ve a https://www.emailjs.com'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _limpiarFormulario() {
    _publicKeyController.clear();
    _serviceIdController.clear();
    _templateIdController.clear();
  }

  void _guardarConfiguracion() {
    if (!_formKey.currentState!.validate()) return;

    // Aquí normalmente guardarías en una base de datos segura
    // Por ahora, solo mostramos un mensaje

    final publicKey = _publicKeyController.text.trim();
    final serviceId = _serviceIdController.text.trim();
    final templateId = _templateIdController.text.trim();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración guardada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Las credenciales han sido guardadas temporalmente.'),
            const SizedBox(height: 16),
            const Text('Para aplicar los cambios:'),
            const Text('1. Actualiza el archivo emailjs_config.dart'),
            const Text('2. Reemplaza los valores con:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('publicKey: "$publicKey"'),
                  Text('serviceId: "$serviceId"'),
                  Text('templateId: "$templateId"'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      'publicKey: "$publicKey",\\nserviceId: "$serviceId",\\ntemplateId: "$templateId"',
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración copiada al portapapeles'),
                ),
              );
            },
            child: const Text('Copiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
