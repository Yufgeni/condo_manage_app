import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../services/user_service.dart';
import '../services/report_service.dart';

class GuardProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final ReportService _reportService = ReportService();

  UserModel? _guard;
  UserModel? _guardOnDuty;
  final List<ReportModel> _myReports = [];
  bool _isLoading = false;

  UserModel? get guard => _guard;
  UserModel? get guardOnDuty => _guardOnDuty;
  List<ReportModel> get myReports => _myReports;
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

  Future<void> fetchMyReports(String authorId) async {
    _isLoading = true;
    notifyListeners();
    final reports = await _reportService.getReportsByAuthor(authorId);
    _myReports.clear();
    _myReports.addAll(reports);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadReport({
    required File image,
    required String title,
    required String description,
    required String authorId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final newReport = ReportModel(
      id: '',
      title: title,
      description: description,
      createdAt: DateTime.now(),
      createdBy: authorId,
    );

    final success = await _reportService.createReport(newReport, image);
    if (success) {
      await fetchMyReports(authorId);
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
