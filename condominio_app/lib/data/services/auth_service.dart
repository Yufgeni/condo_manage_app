import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  // Mock users - Replace with real API calls
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'email': AppConstants.adminEmail,
      'password': 'admin123',
      'name': 'Administrador',
      'role': AppConstants.roleAdmin,
    },
    {
      'id': '2',
      'email': 'residente@condominio.com',
      'password': 'res123',
      'name': 'Juan Pérez',
      'role': AppConstants.roleResident,
    },
    {
      'id': '3',
      'email': 'vigilante@condominio.com',
      'password': 'vig123',
      'name': 'Carlos López',
      'role': AppConstants.roleGuard,
    },
  ];

  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    try {
      final user = _mockUsers.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
      );
      return UserModel.fromJson(user);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}