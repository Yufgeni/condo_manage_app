import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, residents(unit_number)')
          .order('name');
      
      return (response as List).map((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting users: $e');
      }
      return [];
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

  Stream<UserModel?> getGuardOnDutyStream() {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .map((data) {
          final guard = data.firstWhere(
            (element) => element['role'] == 'guard' && element['is_on_duty'] == true,
            orElse: () => {},
          );
          return guard.isNotEmpty ? UserModel.fromJson(guard) : null;
        });
  }

  Future<bool> setGuardOnDuty(String userId) async {
    try {
      // 1. Poner a todos los vigilantes fuera de turno
      await _supabase
          .from('profiles')
          .update({'is_on_duty': false})
          .eq('role', 'guard');

      // 2. Activar al vigilante seleccionado
      await _supabase
          .from('profiles')
          .update({'is_on_duty': true})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error setting guard on duty: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      // 1. Eliminar vehículos del residente si existen
      final residentResponse = await _supabase
          .from('residents')
          .select('id')
          .eq('profile_id', userId)
          .maybeSingle();
      
      if (residentResponse != null) {
        final residentId = residentResponse['id'];
        
        // 2. Eliminar pagos asociados (CUIDADO: Esto borra historial financiero)
        await _supabase.from('payments').delete().eq('resident_id', residentId);
        
        // 3. Eliminar visitantes asociados
        await _supabase.from('visitors').delete().eq('resident_id', residentId);
        
        // 4. Eliminar vehículos asociados
        await _supabase.from('vehicles').delete().eq('resident_id', residentId);
        
        // 5. Eliminar el registro en la tabla 'residents'
        await _supabase.from('residents').delete().eq('id', residentId);
      }

      // 6. Eliminar el perfil (esto dispara el borrado en Auth si hay un trigger, 
      // o simplemente limpia la tabla profiles)
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
      final response = await _supabase.rpc(
        'verify_user_password',
        params: {'password_to_check': password},
      );
      return response as bool;
    } catch (e) {
      debugPrint('Error verificando contraseña vía RPC: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      return false;
    }
  }

  Future<bool> adminUpdateUserPassword(String userId, String newPassword) async {
    try {
      await _supabase.rpc('admin_change_password', params: {
        'target_user_id': userId,
        'new_password': newPassword,
      });
      return true;
    } catch (e) {
      debugPrint('Error admin updating password: $e');
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
    String? unitNumber,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
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

      if (response.user != null && role == 'resident') {
        await _supabase.from('residents').insert({
          'profile_id': response.user!.id,
          'unit_number': unitNumber ?? 'S/N',
          'phone': phone,
        });
      }
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }
}