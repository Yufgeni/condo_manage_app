import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resident_model.dart';

class ResidentService {
  final _supabase = Supabase.instance.client;

  Future<List<ResidentModel>> getAllResidents() async {
    try {
      final response = await _supabase
          .from('residents')
          .select('*, profiles(*)');
      
      return (response as List).map((data) {
        // Aplanar los datos del perfil dentro del modelo del residente
        final profile = data['profiles'];
        return ResidentModel.fromJson({
          ...data,
          'name': profile['name'],
          'email': profile['email'],
          'photoUrl': profile['photo_url'],
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
          .select('*, profiles(*)')
          .eq('profile_id', userId)
          .single();
      
      final profile = response['profiles'];
      return ResidentModel.fromJson({
        ...response,
        'name': profile['name'],
        'email': profile['email'],
        'photoUrl': profile['photo_url'],
      });
    } catch (e) {
      print('Error al obtener residente: $e');
      return null;
    }
  }
}