import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/guard_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/image_picker_widget.dart';

class GuardUploadScreen extends StatefulWidget {
  const GuardUploadScreen({Key? key}) : super(key: key);

  @override
  State<GuardUploadScreen> createState() => _GuardUploadScreenState();
}

class _GuardUploadScreenState extends State<GuardUploadScreen> {
  final _textController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen primero')),
      );
      return;
    }
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega una descripción')),
      );
      return;
    }

    final provider = Provider.of<GuardProvider>(context, listen: false);
    final success = await provider.uploadImageWithText(
      _selectedImage!,
      _textController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Reporte subido exitosamente' : 'Error al subir'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuardProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Subir Reporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Imagen del reporte',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ImagePickerWidget(
              selectedImage: _selectedImage,
              onImageSelected: (file) => setState(() => _selectedImage = file),
            ),
            const SizedBox(height: 24),
            const Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Escribe una descripción breve',
              controller: _textController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Subir reporte',
              onPressed: _upload,
              isLoading: provider.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}