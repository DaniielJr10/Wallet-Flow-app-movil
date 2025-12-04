import 'package:flutter/material.dart';
import 'faq_modelos.dart';
import 'faq_datos.dart';

/// Widgets para las tarjetas y elementos de pregunta
class FAQWidgetsTarjetas {
  /// Construye una tarjeta de pregunta frecuente con animaciones
  static Widget buildTarjetaPregunta({
    required PreguntaFrecuente pregunta,
    required Animation<double> animacion,
    int? index,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animacion,
        curve: Interval(
          (index ?? 0) * 0.1,
          1.0,
          curve: Curves.easeOutBack,
        ),
      )),
      child: FadeTransition(
        opacity: animacion,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          child: Theme(
            data: ThemeData(
              dividerColor: Colors.transparent,
              expansionTileTheme: const ExpansionTileThemeData(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
              ),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(20),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              leading: _buildIconoPregunta(pregunta),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChipCategoria(pregunta.categoria),
                  const SizedBox(height: 8),
                  Text(
                    pregunta.pregunta,
                    style: FAQConstantes.estiloPregunta,
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FAQConstantes.colorPrimario.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.expand_more,
                  color: FAQConstantes.colorPrimario,
                  size: 20,
                ),
              ),
              children: [
                _buildContenidoRespuesta(pregunta),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el ícono de la pregunta con color de categoría
  static Widget _buildIconoPregunta(PreguntaFrecuente pregunta) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: pregunta.colorIcono.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pregunta.colorIcono.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        pregunta.icono,
        color: pregunta.colorIcono,
        size: 24,
      ),
    );
  }

  /// Construye el chip de categoría
  static Widget _buildChipCategoria(String categoria) {
    // Encontrar la categoría enum correspondiente
    final categoriaEnum = CategoriaFAQ.values.firstWhere(
      (cat) => cat.nombre == categoria,
      orElse: () => CategoriaFAQ.general,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoriaEnum.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: categoriaEnum.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoriaEnum.icono,
            size: 12,
            color: categoriaEnum.color,
          ),
          const SizedBox(width: 4),
          Text(
            categoria,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: categoriaEnum.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido de la respuesta
  static Widget _buildContenidoRespuesta(PreguntaFrecuente pregunta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregunta.respuesta,
            style: FAQConstantes.estiloRespuesta,
          ),
          const SizedBox(height: 16),
          _buildAccionesRespuesta(pregunta),
        ],
      ),
    );
  }

  /// Construye las acciones disponibles en la respuesta
  static Widget _buildAccionesRespuesta(PreguntaFrecuente pregunta) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: pregunta.palabrasClave.take(3).map((palabra) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  palabra,
                  style: TextStyle(
                    fontSize: 10,
                    color: FAQConstantes.colorTextoSecundario,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _buildBotonUtil(),
      ],
    );
  }

  /// Construye el botón "¿Te fue útil?"
  static Widget _buildBotonUtil() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FAQConstantes.colorPrimario.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.thumb_up_outlined,
            size: 14,
            color: FAQConstantes.colorPrimario,
          ),
          const SizedBox(width: 4),
          Text(
            '¿Útil?',
            style: TextStyle(
              fontSize: 10,
              color: FAQConstantes.colorPrimario,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de categoría para navegación rápida
  static Widget buildTarjetaCategoria({
    required CategoriaFAQ categoria,
    required int cantidadPreguntas,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoria.color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: categoria.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                categoria.icono,
                color: categoria.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              categoria.nombre,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: FAQConstantes.colorTexto,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$cantidadPreguntas pregunta${cantidadPreguntas != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: FAQConstantes.colorTextoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la vista en grilla de categorías
  static Widget buildGrillaCategorias({
    required Function(CategoriaFAQ) onCategoriaSeleccionada,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: CategoriaFAQ.values.length,
        itemBuilder: (context, index) {
          final categoria = CategoriaFAQ.values[index];
          final cantidadPreguntas = FAQDatos.obtenerPorCategoriaEnum(categoria).length;
          
          return buildTarjetaCategoria(
            categoria: categoria,
            cantidadPreguntas: cantidadPreguntas,
            onTap: () => onCategoriaSeleccionada(categoria),
          );
        },
      ),
    );
  }
}