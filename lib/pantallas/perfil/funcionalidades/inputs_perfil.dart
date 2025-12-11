/// WIDGETS DE ENTRADA DE TEXTO
/// Componente reutilizable para los campos del formulario de perfil.
/// Gestiona los estilos de borde, colores y estado (habilitado/deshabilitado)
/// para mantener una apariencia uniforme en toda la pantalla.
import 'package:flutter/material.dart';
import 'utils_perfil.dart';

class CampoTextoPerfil extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final bool habilitado;
  final TextInputType tipoTeclado;
  final int lineasMaximas;
  final String? Function(String?)? validador;
  final bool mostrarIconoEditar;
  final Future<void> Function(String)? onGuardarCambio;
  final Color? iconColor;
  final Color? fillColor;

  const CampoTextoPerfil({
    super.key,
    required this.controller,
    required this.label,
    required this.icono,
    required this.habilitado,
    this.tipoTeclado = TextInputType.text,
    this.lineasMaximas = 1,
    this.validador,
    this.mostrarIconoEditar = false,
    this.onGuardarCambio,
  this.iconColor,
  this.fillColor,
  });

  @override
  State<CampoTextoPerfil> createState() => _CampoTextoPerfilState();
}

class _CampoTextoPerfilState extends State<CampoTextoPerfil> {
  bool _estEditando = false;
  bool _guardando = false;
  late String _valorOriginal;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _valorOriginal = widget.controller.text;
    _focusNode = FocusNode();
  }

  void _activarEdicion() {
    print('Activando edición para: ${widget.label}'); // Debug
    setState(() {
      _estEditando = true;
      _valorOriginal = widget.controller.text;
    });
    print('Estado editando: $_estEditando'); // Debug
    // Solicitar foco y mover cursor al final
    Future.microtask(() {
      if (mounted) {
        _focusNode.requestFocus();
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );
      }
    });
  }

  Future<void> _guardarCambios() async {
    if (_guardando) return;
    
    setState(() => _guardando = true);
    
    try {
      if (widget.onGuardarCambio != null) {
        await widget.onGuardarCambio!(widget.controller.text);
      }
      setState(() {
        _estEditando = false;
        _valorOriginal = widget.controller.text;
      });
    } catch (e) {
      // Revertir cambios en caso de error
      widget.controller.text = _valorOriginal;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  void _cancelarEdicion() {
    widget.controller.text = _valorOriginal;
    setState(() => _estEditando = false);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool puedeEditar = widget.habilitado || _estEditando;
    print('Build ${widget.label}: habilitado=${widget.habilitado}, editando=$_estEditando, mostrarIcono=${widget.mostrarIconoEditar}'); // Debug
    
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!_estEditando && widget.mostrarIconoEditar && !widget.habilitado) {
          _activarEdicion();
        }
      },
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        enabled: puedeEditar,
        keyboardType: widget.tipoTeclado,
        maxLines: widget.lineasMaximas,
        validator: widget.validador,
        onFieldSubmitted: _estEditando ? (_) => _guardarCambios() : null,
        decoration: InputDecoration(
           labelText: widget.label,
           prefixIcon: Icon(
             widget.icono,
             color: widget.iconColor ?? (puedeEditar ? UtilsPerfil.colorPrincipal : Colors.grey),
           ),
        suffixIcon: _buildSuffixIcon(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2ecc71)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 1.5),
        ),
        filled: true,
        fillColor: widget.fillColor ?? (
          puedeEditar 
            ? Colors.white 
            : widget.mostrarIconoEditar 
                ? UtilsPerfil.colorPrincipal.withOpacity(0.05)
                : const Color(0xFFF9FAFB)
        ),
        labelStyle: TextStyle(
          color: puedeEditar ? const Color(0xFF374151) : Colors.grey,
        ),
      ),
      style: TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
      ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (_guardando) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_estEditando) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _cancelarEdicion,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 4),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 16,
              ),
            ),
          ),
          InkWell(
            onTap: _guardarCambios,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: UtilsPerfil.colorPrincipal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.check,
                color: UtilsPerfil.colorPrincipal,
                size: 16,
              ),
            ),
          ),
        ],
      );
    }

    if (widget.mostrarIconoEditar && !widget.habilitado) {
      print('Mostrando icono de editar para: ${widget.label}'); // Debug
      return IconButton(
        onPressed: () {
          print('Tap en icono de editar para: ${widget.label}'); // Debug
          _activarEdicion();
        },
        icon: const Icon(Icons.edit_outlined, size: 20, color: UtilsPerfil.colorPrincipal),
        splashRadius: 20,
      );
    }

    return null;
  }
}