import 'package:flutter/material.dart';
import 'faq_modelos.dart';
import 'faq_datos.dart';

/// Widgets principales para la pantalla de FAQ
class FAQWidgetsPrincipales {
  /// Construye el header principal con estadísticas
  static Widget buildHeaderPrincipal() {
    final totalPreguntas = FAQDatos.preguntasFrecuentes.length;
    final totalCategorias = FAQDatos.obtenerCategorias().length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FAQConstantes.colorPrimario,
            FAQConstantes.colorPrimario.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FAQConstantes.colorPrimario.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.help_center,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                      'Encuentra respuestas rápidas',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildEstadistica(
                  Icons.quiz,
                  '$totalPreguntas',
                  'Preguntas',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEstadistica(
                  Icons.category,
                  '$totalCategorias',
                  'Categorías',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildEstadistica(IconData icono, String numero, String etiqueta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icono, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            numero,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            etiqueta,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la barra de búsqueda
  static Widget buildBarraBusqueda({
    required TextEditingController controller,
    required VoidCallback onClear,
    String? hintText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText ?? 'Buscar preguntas, categorías o palabras clave...',
            hintStyle: TextStyle(
              color: FAQConstantes.colorTextoSecundario.withOpacity(0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: FAQConstantes.colorPrimario,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: FAQConstantes.colorTextoSecundario,
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  /// Construye el filtro de categorías horizontal
  static Widget buildFiltroCategorias({
    required String categoriaSeleccionada,
    required Function(String) onCategoriaSeleccionada,
  }) {
    final categorias = ['Todas', ...FAQDatos.obtenerCategorias()];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final isSelected = categoria == categoriaSeleccionada;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(categoria),
              selected: isSelected,
              onSelected: (_) => onCategoriaSeleccionada(categoria),
              backgroundColor: Colors.white,
              selectedColor: FAQConstantes.colorPrimario.withOpacity(0.1),
              checkmarkColor: FAQConstantes.colorPrimario,
              labelStyle: TextStyle(
                color: isSelected 
                    ? FAQConstantes.colorPrimario 
                    : FAQConstantes.colorTextoSecundario,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? FAQConstantes.colorPrimario 
                      : FAQConstantes.colorTextoSecundario.withOpacity(0.3),
                ),
              ),
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }

  /// Construye el widget cuando no se encuentran resultados
  static Widget buildSinResultados({String? termino}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FAQConstantes.colorTextoSecundario.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 60,
                color: FAQConstantes.colorTextoSecundario.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              termino != null && termino.isNotEmpty
                  ? 'No encontramos resultados para "$termino"'
                  : 'No hay preguntas en esta categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FAQConstantes.colorTexto,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              termino != null && termino.isNotEmpty
                  ? 'Intenta con otros términos o explora las categorías'
                  : 'Selecciona otra categoría para ver preguntas',
              style: TextStyle(
                fontSize: 14,
                color: FAQConstantes.colorTextoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Limpiar búsqueda o cambiar categoría
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Ver todas las preguntas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FAQConstantes.colorPrimario,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón para contactar soporte
  static Widget buildBotonContactarSoporte(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Nuestro equipo está aquí para ayudarte',
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
      ),
    );
  }
}