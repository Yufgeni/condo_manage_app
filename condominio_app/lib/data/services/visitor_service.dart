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

  Future<bool> addVisitor(VisitorModel visitor) async {
    try {
      await _supabase.from('visitors').insert(visitor.toJson());
      return true;
    } catch (e) {
      print('Error al registrar visita en Supabase: $e');
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