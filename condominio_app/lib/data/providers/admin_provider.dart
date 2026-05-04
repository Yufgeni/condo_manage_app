import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/image_service.dart';

class AdminProvider extends ChangeNotifier {
  final ImageService _imageService = ImageService();
  
  List<ReportModel> _reports = [];
  bool _isLoading = false;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<bool> uploadReport({
    required File image,
    required String description,
    required String authorId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _imageService.uploadImage(image);
      if (imageUrl != null) {
        final newReport = ReportModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: description,
          imageUrl: imageUrl,
          date: DateTime.now(),
          authorId: authorId,
        );
        _reports.insert(0, newReport);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error uploading report: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}