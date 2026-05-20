import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/services/image_service.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final void Function(File) onImageSelected;
  final ImageService _imageService = ImageService();

  ImagePickerWidget({
    super.key,
    this.selectedImage,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              selectedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: const Icon(Icons.image, size: 60, color: Colors.grey),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final file = await _imageService.pickImageFromCamera();
                  if (file != null) onImageSelected(file);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final file = await _imageService.pickImageFromGallery();
                  if (file != null) onImageSelected(file);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
