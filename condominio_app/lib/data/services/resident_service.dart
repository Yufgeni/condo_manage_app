import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resident_model.dart';

class ResidentService {
  final _supabase = Supabase.instance.client;

  Future<List<ResidentModel>> getAllResidents() async {
    try {
      // 1. Fetch all residents from residents table
      final residentsResponse = await _supabase
          .from('residents')
          .select('*, profiles!residents_profile_id_fkey(*), vehicles(*)');
      
      final Map<String, ResidentModel> residentMap = {};

      for (var data in (residentsResponse as List)) {
        final profile = data['profiles'];
        residentMap[data['profile_id']] = ResidentModel.fromJson({
          ...data,
          'name': profile['name'],
          'email': profile['email'],
          'phone': profile['phone'],
          'photoUrl': profile['photo_url'],
          'vehicles': data['vehicles'],
        });
      }

      // 2. Fetch all profiles where (role = 'resident') OR (role = 'admin' AND lives_in_condo = true)
      final profilesResponse = await _supabase
          .from('profiles')
          .select()
          .or('role.eq.resident,and(role.eq.admin,lives_in_condo.eq.true)');

      for (var profile in (profilesResponse as List)) {
        final String profileId = profile['id'];
        if (!residentMap.containsKey(profileId)) {
          // If not in residents table, create a dummy resident model for selection
          residentMap[profileId] = ResidentModel(
            id: '', 
            profileId: profileId,
            name: profile['name'],
            email: profile['email'],
            phone: profile['phone'],
            unitNumber: 'S/N',
            cars: [],
          );
        }
      }

      return residentMap.values.toList();
    } catch (e) {
      print('Error al obtener residentes: $e');
      return [];
    }
  }

  Future<ResidentModel?> getResidentByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('residents')
          .select('*, profiles!residents_profile_id_fkey(*), vehicles(*)')
          .eq('profile_id', userId)
          .maybeSingle();
      
      if (response != null) {
        final profile = response['profiles'];
        return ResidentModel.fromJson({
          ...response,
          'name': profile['name'],
          'email': profile['email'],
          'phone': profile['phone'],
          'photoUrl': profile['photo_url'],
          'vehicles': response['vehicles'],
        });
      }

      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return ResidentModel(
        id: '',
        profileId: userId,
        name: profileResponse['name'] ?? '',
        email: profileResponse['email'] ?? '',
        phone: profileResponse['phone'] ?? '',
        unitNumber: '',
        cars: [],
      );
    } catch (e) {
      print('Error al obtener residente: $e');
      return null;
    }
  }

  Future<bool> updateProfilePhone(String profileId, String phone) async {
    try {
      await _supabase.from('profiles').update({'phone': phone}).eq('id', profileId);
      // También intentamos actualizar en la tabla residents si existe
      await _supabase.from('residents').update({'phone': phone}).eq('profile_id', profileId);
      return true;
    } catch (e) {
      print('Error al actualizar teléfono: $e');
      return false;
    }
  }

  Future<bool> updateResidentUnitNumber(String profileId, String unitNumber) async {
    try {
      // Intentamos actualizar primero
      final response = await _supabase
          .from('residents')
          .update({'unit_number': unitNumber})
          .eq('profile_id', profileId)
          .select();

      // Si no se actualizó nada (lista vacía), significa que el registro no existe
      if ((response as List).isEmpty) {
        await _supabase.from('residents').insert({
          'profile_id': profileId,
          'unit_number': unitNumber,
        });
      }

      return true;
    } catch (e) {
      print('Error al actualizar número de casa: $e');
      return false;
    }
  }

  Future<bool> addVehicle(String profileId, CarInfo car) async {
    try {
      var residentResponse = await _supabase
          .from('residents')
          .select('id')
          .eq('profile_id', profileId)
          .maybeSingle();
      
      String residentId;
      if (residentResponse == null) {
        final newResident = await _supabase.from('residents').insert({
          'profile_id': profileId,
          'unit_number': 'S/N'
        }).select('id').single();
        residentId = newResident['id'].toString();
      } else {
        residentId = residentResponse['id'].toString();
      }

      await _supabase.from('vehicles').insert({
        'resident_id': residentId,
        'brand': car.brand,
        'model_year': car.year,
        'color': car.color,
        'plates': car.plates,
      });
      return true;
    } catch (e) {
      print('Error al añadir vehículo: $e');
      return false;
    }
  }

  Future<bool> updateVehicle(CarInfo car) async {
    try {
      if (car.id == null) return false;
      await _supabase.from('vehicles').update({
        'brand': car.brand,
        'model_year': car.year,
        'color': car.color,
        'plates': car.plates,
      }).eq('id', car.id!);
      return true;
    } catch (e) {
      print('Error al actualizar vehículo: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await _supabase.from('vehicles').delete().eq('id', vehicleId);
      return true;
    } catch (e) {
      print('Error al eliminar vehículo: $e');
      return false;
    }
  }
}