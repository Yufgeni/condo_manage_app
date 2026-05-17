import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('name');
      
      return (response as List).map((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<UserModel?> getGuardOnDuty() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'guard')
          .eq('is_on_duty', true)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting guard on duty: $e');
      return null;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      // Deleting from auth.users requires service_role or a custom function.
      // For now, we delete from profiles (cascade might handle auth if configured, 
      // but usually auth deletion is separate). 
      // Given we are using RPC or Supabase Admin is not easy from client, 
      // we might just delete the profile or use a dedicated edge function.
      // However, for this exercise, we'll try deleting from profiles.
      await _supabase.from('profiles').delete().eq('id', userId);
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<bool> updateRole(String userId, String newRole) async {
    try {
      await _supabase.from('profiles').update({'role': newRole}).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating role: $e');
      return false;
    }
  }

  Future<bool> updateDutyStatus(String userId, bool isOnDuty) async {
    try {
      await _supabase.from('profiles').update({'is_on_duty': isOnDuty}).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating duty status: $e');
      return false;
    }
  }

  Future<bool> verifyPassword(String password) async {
    try {
      final email = _supabase.auth.currentUser?.email;
      if (email == null) return false;
      
      // Verify by attempting to sign in (not ideal but works for validation)
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> createProfile({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String role,
    required DateTime birthDate,
    required int age,
    String? phone,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'last_name': lastName,
          'role': role,
          'birth_date': birthDate.toIso8601String(),
          'age': age,
          'phone': phone,
        },
      );
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }
}