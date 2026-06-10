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

      // 6. Eliminar el perfil
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
  
  Future<bool> setTreasurer(String userId) async {
    try {
      // 1. Quitar el cargo de tesorero a todos los perfiles
      await _supabase
          .from('profiles')
          .update({'is_treasurer': false});

      // 2. Activar al nuevo tesorero
      await _supabase
          .from('profiles')
          .update({'is_treasurer': true})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error setting treasurer: $e');
      return false;
    }
  }

  Future<AuthResponse> createProfile({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String role,
    required DateTime birthDate,
    required int age,
    String? phone,
    String? unitNumber,
    bool livesInCondo = true,
    bool isTreasurer = false,
  }) async {
    // No usamos try-catch aquí para que el Provider capture la excepción específica de Supabase
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
        'lives_in_condo': livesInCondo,
      },
    );

    if (response.user != null) {
      // 1. Manejo de tabla residents si aplica
      if (role == 'resident' || (role == 'admin' && unitNumber != null)) {
        await _supabase.from('residents').insert({
          'profile_id': response.user!.id,
          'unit_number': unitNumber ?? 'S/N',
          'phone': phone,
        });
      }

      // 2. Asegurar que lives_in_condo e is_treasurer se guarden en profiles
      await _supabase.from('profiles').update({
        'lives_in_condo': livesInCondo,
        'is_treasurer': isTreasurer,
      }).eq('id', response.user!.id);

      // 3. Si se marcó como tesorero, asegurar la unicidad
      if (isTreasurer) {
        await setTreasurer(response.user!.id);
      }
    }

    return response;
  }

  Future<bool> updateFullProfile({
    required String userId,
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String role,
    required bool livesInCondo,
    String? unitNumber,
    bool isTreasurer = false,
  }) async {
    try {
      // 1. Update email in Auth if it changed
      try {
        await _supabase.rpc('admin_update_user_email', params: {
          'target_user_id': userId,
          'new_email': email,
        });
      } catch (e) {
        debugPrint('Warning: RPC admin_update_user_email failed. Email not updated in Auth: $e');
      }

      // 2. Update profiles table
      await _supabase.from('profiles').update({
        'name': name,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': role,
        'lives_in_condo': livesInCondo,
      }).eq('id', userId);

      // 3. Si es tesorero, manejar la unicidad
      if (isTreasurer) {
        await setTreasurer(userId);
      } else {
        // Si ya era tesorero y se le quita, simplemente actualizamos su registro
        await _supabase.from('profiles').update({'is_treasurer': false}).eq('id', userId);
      }

      // 4. Handle residents table
      if (role == 'resident' || (role == 'admin' && unitNumber != null)) {
        final residentResponse = await _supabase
            .from('residents')
            .select('id')
            .eq('profile_id', userId)
            .maybeSingle();

        if (residentResponse != null) {
          await _supabase.from('residents').update({
            'unit_number': unitNumber ?? 'S/N',
            'phone': phone,
          }).eq('profile_id', userId);
        } else {
          await _supabase.from('residents').insert({
            'profile_id': userId,
            'unit_number': unitNumber ?? 'S/N',
            'phone': phone,
          });
        }
      }

      return true;
    } catch (e) {
      print('Error updating full profile: $e');
      return false;
    }
  }

  Future<String?> uploadSignature(String userId, Uint8List signatureData) async {
    try {
      final fileName = 'sig_$userId.png';
      final path = 'signatures/$fileName';
      
      await _supabase.storage.from('admin-signatures').uploadBinary(
        path,
        signatureData,
        fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
      );

      final signatureUrl = _supabase.storage.from('admin-signatures').getPublicUrl(path);

      await _supabase.from('profiles').update({'signature_url': signatureUrl}).eq('id', userId);

      return signatureUrl;
    } catch (e) {
      debugPrint('Error uploading signature: $e');
      return null;
    }
  }
}
