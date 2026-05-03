import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) return File(image.path);
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) return File(image.path);
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<String?> uploadImage(File imageFile) async {
    // TODO: Implement actual upload to your backend/storage
    await Future.delayed(const Duration(seconds: 2));
    return 'https://picsum.photos/400/200';
  }
}