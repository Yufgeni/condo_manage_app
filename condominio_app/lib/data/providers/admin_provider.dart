import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/report_service.dart';

class AdminProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final ReportService _reportService = ReportService();
  
  final List<ReportModel> _reports = [];
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReportModel> get reports => _reports;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    _users = await _userService.getAllUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();
    final newReports = await _reportService.getAllReports();
    _reports.clear();
    _reports.addAll(newReports);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> resolveReport(String reportId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _reportService.updateReportStatus(reportId, 'resolved');
    if (success) {
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWith(status: 'resolved');
      }
    }
    _isLoading = false;
    notifyListeners();
    return success;
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
      await fetchReports();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // --- Otros métodos existentes ---
  Future<bool> verifyPassword(String password) async {
    return await _userService.verifyPassword(password);
  }

  Future<bool> createProfile({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String role,
    DateTime? birthDate,
    int? age,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _userService.createProfile(
      email: email,
      password: password,
      name: name,
      lastName: lastName,
      role: role,
      birthDate: birthDate ?? DateTime.now(),
      age: age ?? 0,
      phone: phone,
    );

    if (!success) {
      _errorMessage = 'Error al crear el perfil';
    } else {
      await fetchUsers();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _userService.deleteUser(userId);
    if (success) {
      _users.removeWhere((u) => u.id == userId);
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    _isLoading = true;
    notifyListeners();
    final success = await _userService.updateRole(userId, newRole);
    if (success) {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = UserModel(
          id: _users[index].id,
          email: _users[index].email,
          name: _users[index].name,
          lastName: _users[index].lastName,
          role: newRole,
          photoUrl: _users[index].photoUrl,
          isOnDuty: _users[index].isOnDuty,
          phone: _users[index].phone,
        );
      }
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateDutyStatus(String userId, bool isOnDuty) async {
    _isLoading = true;
    notifyListeners();
    final success = await _userService.updateDutyStatus(userId, isOnDuty);
    if (success) {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = UserModel(
          id: _users[index].id,
          email: _users[index].email,
          name: _users[index].name,
          lastName: _users[index].lastName,
          role: _users[index].role,
          photoUrl: _users[index].photoUrl,
          isOnDuty: isOnDuty,
          phone: _users[index].phone,
        );
      }
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> adminUpdatePassword(String userId, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    final success = await _userService.adminUpdateUserPassword(userId, newPassword);
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
