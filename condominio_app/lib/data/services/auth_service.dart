import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await _getUserProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error en login: $e');
      }
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null && session.user != null) {
        return await _getUserProfile(session.user.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al recuperar sesión: $e');
      }
      return null;
    }
  }

  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final userData = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener perfil: $e');
      }
      return null;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      print('Error en updatePassword: $e');
      return false;
    }
  }
}
