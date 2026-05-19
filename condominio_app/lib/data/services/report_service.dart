import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';

class ReportService {
  final _supabase = Supabase.instance.client;

  Future<List<ReportModel>> getAllReports() async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => ReportModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener reportes: $e');
      return [];
    }
  }

  Future<List<ReportModel>> getReportsByAuthor(String authorId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('created_by', authorId)
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => ReportModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener mis reportes: $e');
      return [];
    }
  }

  Future<bool> createReport(ReportModel report, File imageFile) async {
    try {
      // 1. Subir imagen al Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${report.createdBy}.jpg';
      final path = 'reports/$fileName';
      
      await _supabase.storage.from('report-images').upload(path, imageFile);
      
      // 2. Obtener URL pública
      final imageUrl = _supabase.storage.from('report-images').getPublicUrl(path);

      // 3. Guardar en base de datos
      await _supabase.from('reports').insert({
        'title': report.title,
        'description': report.description,
        'image_url': imageUrl,
        'created_by': report.createdBy,
        'status': 'pending',
      });
      
      return true;
    } catch (e) {
      print('Error al crear reporte: $e');
      return false;
    }
  }

  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      await _supabase
          .from('reports')
          .update({'status': status})
          .eq('id', reportId);
      return true;
    } catch (e) {
      print('Error al actualizar status del reporte: $e');
      return false;
    }
  }
}
