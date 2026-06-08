import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/visitor_model.dart';

class VisitorService {
  final _supabase = Supabase.instance.client;

  /// Obtiene visitas por ID de residente y fecha específica
  Future<List<VisitorModel>> getVisitorsByResidentAndDate(String residentId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      final response = await _supabase
          .from('visitors')
          .select()
          .eq('resident_id', residentId)
          .gte('entry_at', startOfDay)
          .lte('entry_at', endOfDay)
          .order('entry_at', ascending: true);

      return (response as List).map((data) => VisitorModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener visitas por fecha: $e');
      return [];
    }
  }

  /// Obtiene todo el historial de visitas de un residente
  Future<List<VisitorModel>> getAllVisitorsByResident(String residentId) async {
    try {
      final response = await _supabase
          .from('visitors')
          .select()
          .eq('resident_id', residentId)
          .order('entry_at', ascending: false);

      return (response as List).map((data) => VisitorModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener historial completo de visitas: $e');
      return [];
    }
  }

  /// Obtiene historial global filtrado por fechas
  Future<List<VisitorModel>> getGlobalVisitorHistory(DateTime start, DateTime end) async {
    try {
      final startIso = DateTime(start.year, start.month, start.day).toIso8601String();
      final endIso = DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();

      final response = await _supabase
          .from('visitors')
          .select('*, guards:profiles(name)')
          .gte('entry_at', startIso)
          .lte('entry_at', endIso)
          .order('entry_at', ascending: false);

      return (response as List).map((data) => VisitorModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener historial global: $e');
      return [];
    }
  }

  /// Obtiene visitantes que aún no han salido
  Future<List<VisitorModel>> getActiveVisitors() async {
    try {
      final response = await _supabase
          .from('visitors')
          .select('*, guards:profiles(name)')
          .filter('exit_at', 'is', null)
          .order('entry_at', ascending: false);

      return (response as List).map((data) => VisitorModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener visitantes activos: $e');
      return [];
    }
  }

  /// Registra la salida de un visitante
  Future<bool> markVisitorExit(String visitorId) async {
    try {
      await _supabase
          .from('visitors')
          .update({'exit_at': DateTime.now().toIso8601String()})
          .eq('id', visitorId);
      return true;
    } catch (e) {
      print('Error al registrar salida: $e');
      return false;
    }
  }

  Future<bool> addVisitor(VisitorModel visitor) async {
    try {
      await _supabase.from('visitors').insert(visitor.toJson());
      return true;
    } catch (e) {
      print('Error al registrar visita en Supabase: $e');
      return false;
    }
  }

  Future<bool> registerVisitor(VisitorModel visitor, {File? idImage}) async {
    try {
      String? imageUrl;
      
      // 1. Obtener el ID de la tabla 'residents' usando el profile_id
      // El visitor.residentId que recibimos actualmente es el ID de la tabla 'profiles'
      final profileId = visitor.residentId;
      
      final residentResponse = await _supabase
          .from('residents')
          .select('id')
          .eq('profile_id', profileId)
          .maybeSingle();
      
      String finalResidentId;
      
      if (residentResponse == null) {
        // Si por alguna razón el residente no existe en la tabla residents, 
        // lo creamos (esto puede pasar si el usuario es nuevo)
        final newResident = await _supabase
            .from('residents')
            .insert({'profile_id': profileId, 'unit_number': visitor.unitNumber ?? 'N/A'})
            .select('id')
            .single();
        finalResidentId = newResident['id'];
      } else {
        finalResidentId = residentResponse['id'];
      }

      // 2. Subir imagen si existe
      if (idImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${visitor.name.replaceAll(' ', '_')}.jpg';
        final path = 'visitor_ids/$fileName';
        
        await _supabase.storage.from('visitor_ids').upload(path, idImage);
        imageUrl = _supabase.storage.from('visitor_ids').getPublicUrl(path);
      }

      // 3. Preparar datos finales con el resident_id correcto de la tabla 'residents'
      final data = visitor.toJson();
      data['resident_id'] = finalResidentId; // Sobrescribimos con el UUID de la tabla residents
      
      if (imageUrl != null) {
        data['id_image_url'] = imageUrl;
      }

      await _supabase.from('visitors').insert(data);
      return true;
    } catch (e) {
      print('Error al registrar visita: $e');
      return false;
    }
  }

  Future<bool> deleteVisitor(String visitorId) async {
    try {
      await _supabase.from('visitors').delete().eq('id', visitorId);
      return true;
    } catch (e) {
      print('Error al eliminar visita: $e');
      return false;
    }
  }
}