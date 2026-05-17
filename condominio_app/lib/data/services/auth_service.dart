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
        final userData = await _supabase
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}