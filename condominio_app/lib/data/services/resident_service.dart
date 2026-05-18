import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resident_model.dart';

class ResidentService {
  final _supabase = Supabase.instance.client;

  Future<List<ResidentModel>> getAllResidents() async {
    try {
      final response = await _supabase
          .from('residents')
          .select('*, profiles(*), vehicles(*)');
      
      return (response as List).map((data) {
        final profile = data['profiles'];
        return ResidentModel.fromJson({
          ...data,
          'name': profile['name'],
          'email': profile['email'],
          'phone': profile['phone'], // El teléfono ahora está en profiles
          'photoUrl': profile['photo_url'],
          'vehicles': data['vehicles'],
        });
      }).toList();
    } catch (e) {
      print('Error al obtener residentes: $e');
      return [];
    }
  }

  Future<ResidentModel?> getResidentByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('residents')
          .select('*, profiles(*), vehicles(*)')
          .eq('profile_id', userId)
          .maybeSingle();
      
      if (response == null) return null;

      final profile = response['profiles'];
      return ResidentModel.fromJson({
        ...response,
        'name': profile['name'],
        'email': profile['email'],
        'phone': profile['phone'],
        'photoUrl': profile['photo_url'],
        'vehicles': response['vehicles'],
      });
    } catch (e) {
      print('Error al obtener residente: $e');
      return null;
    }
  }

  Future<bool> updateProfilePhone(String profileId, String phone) async {
    try {
      await _supabase.from('profiles').update({'phone': phone}).eq('id', profileId);
      return true;
    } catch (e) {
      print('Error al actualizar teléfono: $e');
      return false;
    }
  }

  Future<bool> addVehicle(String residentId, CarInfo car) async {
    try {
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
}