import 'package:flutter/material.dart';
import 'dart:async';
import 'faq_modelos.dart';
import 'faq_datos.dart';

/// Pantalla de Preguntas Frecuentes simplificada y fácil de usar
class PreguntasFrecuentesPantalla extends StatefulWidget {
  const PreguntasFrecuentesPantalla({super.key});

  @override
  State<PreguntasFrecuentesPantalla> createState() => _PreguntasFrecuentesPantallaState();
}

class _PreguntasFrecuentesPantallaState extends State<PreguntasFrecuentesPantalla> {
  final TextEditingController _busquedaController = TextEditingController();
  List<PreguntaFrecuente> _preguntasFiltradas = [];
  Timer? _timerBusqueda;

  @override
  void initState() {
    super.initState();
    _preguntasFiltradas = FAQDatos.preguntasFrecuentes;
    _busquedaController.addListener(_onBusquedaCambiada);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _timerBusqueda?.cancel();
    super.dispose();
  }

  void _onBusquedaCambiada() {
    _timerBusqueda?.cancel();
    _timerBusqueda = Timer(const Duration(milliseconds: 300), () {
      final termino = _busquedaController.text.trim();
      setState(() {
        if (termino.isEmpty) {
          _preguntasFiltradas = FAQDatos.preguntasFrecuentes;
        } else {
          _preguntasFiltradas = FAQDatos.buscarPreguntas(termino);
        }
      });
    });
  }

  void _limpiarBusqueda() {
    _busquedaController.clear();
    setState(() {
      _preguntasFiltradas = FAQDatos.preguntasFrecuentes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Preguntas Frecuentes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header simple
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981),
                  const Color(0xFF10B981).withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_center,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Centro de Ayuda',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Encuentra respuestas rápidas a tus dudas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Barra de búsqueda
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar pregunta...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF10B981),
                      ),
                      suffixIcon: _busquedaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _limpiarBusqueda,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de preguntas
          Expanded(
            child: _preguntasFiltradas.isEmpty
                ? _buildSinResultados()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _preguntasFiltradas.length,
                    itemBuilder: (context, index) {
                      final pregunta = _preguntasFiltradas[index];
                      return _buildTarjetaPregunta(pregunta);
                    },
                  ),
          ),
          
          // Botón contactar soporte
          _buildBotonContactarSoporte(),
        ],
      ),
    );
  }

  Widget _buildTarjetaPregunta(PreguntaFrecuente pregunta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: pregunta.colorIcono.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            pregunta.icono,
            color: pregunta.colorIcono,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pregunta.colorIcono.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                pregunta.categoria,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: pregunta.colorIcono,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pregunta.pregunta,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pregunta.respuesta,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinResultados() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No encontramos resultados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonContactarSoporte() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.support_agent,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿No encontraste lo que buscas?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'Contáctanos directamente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/contactar-soporte');
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Contactar Soporte'),
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
        ],
      ),
    );
  }
}