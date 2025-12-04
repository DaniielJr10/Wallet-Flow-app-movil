import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  State<CambiarContrasenaScreen> createState() => _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentCtrl = TextEditingController();
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, bool visible, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).colorScheme.primary),
        onPressed: toggle,
      ),
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario no autenticado'), backgroundColor: Colors.red));
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cred = EmailAuthProvider.credential(email: user.email!, password: _currentCtrl.text.trim());
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text.trim());

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Contraseña actualizada'),
            content: const Text('Tu contraseña ha sido actualizada correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al actualizar contraseña.';
      if (e.code == 'wrong-password') msg = 'Contraseña actual incorrecta';
      if (e.code == 'weak-password') msg = 'La nueva contraseña es demasiado débil';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF10B981);
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryGreen, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), title: const Text('Cambiar contraseña')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [primaryGreen.withOpacity(0.95), primaryGreen.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Actualiza tu contraseña', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Mantén tu cuenta segura cambiando tu contraseña regularmente', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _currentCtrl,
                        obscureText: !_showCurrent,
                        decoration: _inputDecoration('Contraseña actual', _showCurrent, () => setState(() => _showCurrent = !_showCurrent)).copyWith(prefixIcon: Icon(Icons.lock_outline, color: primaryGreen)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña actual' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newCtrl,
                        obscureText: !_showNew,
                        decoration: _inputDecoration('Nueva contraseña', _showNew, () => setState(() => _showNew = !_showNew)).copyWith(prefixIcon: Icon(Icons.fingerprint, color: primaryGreen)),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                          if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: !_showConfirm,
                        decoration: _inputDecoration('Confirmar nueva contraseña', _showConfirm, () => setState(() => _showConfirm = !_showConfirm)).copyWith(prefixIcon: Icon(Icons.check_circle_outline, color: primaryGreen)),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirma la nueva contraseña';
                          if (v != _newCtrl.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save, size: 20),
                          label: Text(_isLoading ? 'Guardando...' : 'Actualizar contraseña', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : _submit,
                        ),
                      ),
                    ],
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
