import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/user_service.dart';
import '../../../core/utils/ui_utils.dart';

class SignaturePadScreen extends StatefulWidget {
  const SignaturePadScreen({super.key});

  @override
  State<SignaturePadScreen> createState() => _SignaturePadScreenState();
}

class _SignaturePadScreenState extends State<SignaturePadScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (_controller.isEmpty) {
      UIUtils.showSnackBar(context, 'Por favor dibuje su firma antes de guardar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        if (userId != null) {
          final userService = UserService();
          final url = await userService.uploadSignature(userId, data);
          
          if (url != null && mounted) {
            // Actualizar el usuario localmente en el provider
            final updatedUser = authProvider.currentUser!.copyWith(signatureUrl: url);
            authProvider.updateCurrentUser(updatedUser);
            
            UIUtils.showSnackBar(context, 'Firma guardada correctamente', isError: false);
            Navigator.pop(context);
          } else if (mounted) {
            UIUtils.showSnackBar(context, 'Error al subir la firma');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'Error al procesar la firma: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Firma Digital'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withValues(alpha: 0.1),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta firma se utilizará automáticamente en todos los recibos de pago que generes.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _controller.clear(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveSignature,
                    icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Guardando...' : 'Guardar Firma'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}