import 'package:flutter/material.dart';
import 'dart:io';
import '../models/guard_model.dart';
import '../services/image_service.dart';

class GuardProvider extends ChangeNotifier {
  final ImageService _imageService = ImageService();

  GuardModel? _guard;
  List<Map<String, dynamic>> _uploads = [];
  bool _isLoading = false;

  GuardModel? get guard => _guard;
  List<Map<String, dynamic>> get uploads => _uploads;
  bool get isLoading => _isLoading;

  // Mock guard
  final GuardModel _mockGuard = GuardModel(
    id: '3',
    userId: '3',
    name: 'Carlos López',
    email: 'vigilante@condominio.com',
    phone: '5598765432',
    shift: 'Nocturno',
    isOnDuty: true,
  );

  GuardModel get guardOnDuty => _mockGuard;

  Future<void> loadGuardData(String userId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _guard = _mockGuard;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadImageWithText(File image, String text) async {
    _isLoading = true;
    notifyListeners();
    final url = await _imageService.uploadImage(image);
    if (url != null) {
      _uploads.add({
        'imageUrl': url,
        'text': text,
        'date': DateTime.now().toIso8601String(),
      });
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}