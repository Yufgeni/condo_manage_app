import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/guard_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/image_picker_widget.dart';

class GuardUploadScreen extends StatefulWidget {
  const GuardUploadScreen({super.key});

  @override
  State<GuardUploadScreen> createState() => _GuardUploadScreenState();
}

class _GuardUploadScreenState extends State<GuardUploadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una imagen primero')));
      return;
    }
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos')));
      return;
    }

    final guardProvider = Provider.of<GuardProvider>(context, listen: false);
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;

    if (userId == null) return;

    final success = await guardProvider.uploadReport(
      image: _selectedImage!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      authorId: userId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Reporte subido exitosamente' : 'Error al subir reporte'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        setState(() {
          _selectedImage = null;
          _titleController.clear();
          _descriptionController.clear();
        });
        // Navigate to history after successful upload
        Navigator.pushReplacementNamed(context, AppConstants.routeGuardReports);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guardProvider = Provider.of<GuardProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Reporte de Incidencia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Imagen de la incidencia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ImagePickerWidget(
              selectedImage: _selectedImage,
              onImageSelected: (file) => setState(() => _selectedImage = file),
            ),
            const SizedBox(height: 24),
            const Text('Detalles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Título breve',
              controller: _titleController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Descripción de lo sucedido',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Subir reporte',
              onPressed: _upload,
              isLoading: guardProvider.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
