import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/image_service.dart';
import '../services/user_service.dart';

class GuardProvider extends ChangeNotifier {
  final ImageService _imageService = ImageService();
  final UserService _userService = UserService();

  UserModel? _guard;
  UserModel? _guardOnDuty;
  List<Map<String, dynamic>> _uploads = [];
  bool _isLoading = false;

  UserModel? get guard => _guard;
  UserModel? get guardOnDuty => _guardOnDuty;
  List<Map<String, dynamic>> get uploads => _uploads;
  bool get isLoading => _isLoading;

  Future<void> loadGuardData(String userId) async {
    _isLoading = true;
    notifyListeners();
    _guard = await _userService.getUserById(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchGuardOnDuty() async {
    _isLoading = true;
    notifyListeners();
    _guardOnDuty = await _userService.getGuardOnDuty();
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