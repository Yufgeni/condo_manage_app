import 'package:flutter/material.dart';
import '../models/visitor_model.dart';
import '../models/resident_model.dart';
import '../services/visitor_service.dart';
import '../services/resident_service.dart';

class VisitorProvider extends ChangeNotifier {
  final VisitorService _visitorService = VisitorService();
  final ResidentService _residentService = ResidentService();
  
  List<VisitorModel> _visitors = [];
  List<VisitorModel> _allResidentVisitors = []; // New list for all visitors
  bool _isLoading = false;

  List<VisitorModel> get visitors => _visitors;
  List<VisitorModel> get allResidentVisitors => _allResidentVisitors;
  bool get isLoading => _isLoading;

  Future<void> loadAllVisitorsByResident(String profileId) async {
    _isLoading = true;
    notifyListeners();
    
    final resident = await _residentService.getResidentByUserId(profileId);
    
    if (resident != null && resident.id.isNotEmpty) {
      _allResidentVisitors = await _visitorService.getAllVisitorsByResident(resident.id);
    } else {
      _allResidentVisitors = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVisitorsByDay(String profileId, DateTime date) async {
    _isLoading = true;
    notifyListeners();
    
    final resident = await _residentService.getResidentByUserId(profileId);
    
    if (resident != null && resident.id.isNotEmpty) {
      _visitors = await _visitorService.getVisitorsByResidentAndDate(resident.id, date);
    } else {
      _visitors = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addVisitor(VisitorModel visitor, String profileId) async {
    _isLoading = true;
    notifyListeners();
    
    String finalResidentId = visitor.residentId;

    // Si el resident_id está vacío (como en el caso del Admin la primera vez)
    // Usamos el servicio de residentes que ya tiene la lógica de "crear si no existe"
    if (finalResidentId.isEmpty) {
      // Intentamos registrar un vehículo dummy o simplemente forzar la creación del resident
      // Usaremos la lógica de addVehicle que ya maneja la creación de la ficha de residente
      final success = await _residentService.addVehicle(profileId, CarInfo(brand: 'PROPIO', year: '', color: '', plates: 'INTERNO'));
      
      if (success) {
        final resident = await _residentService.getResidentByUserId(profileId);
        if (resident != null) finalResidentId = resident.id;
      }
    }

    if (finalResidentId.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final success = await _visitorService.addVisitor(VisitorModel(
      id: visitor.id,
      residentId: finalResidentId,
      name: visitor.name,
      carBrand: visitor.carBrand,
      carColor: visitor.carColor,
      carPlates: visitor.carPlates,
      date: visitor.date,
    ));

    if (success) {
      _visitors = await _visitorService.getAllVisitorsByResident(finalResidentId);
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> removeVisitor(String visitorId) async {
    _isLoading = true;
    notifyListeners();

    final success = await _visitorService.deleteVisitor(visitorId);
    if (success) {
      _visitors.removeWhere((v) => v.id == visitorId);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
}