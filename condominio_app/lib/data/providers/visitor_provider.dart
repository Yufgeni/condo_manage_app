import 'dart:io';
import 'package:flutter/material.dart';
import '../models/visitor_model.dart';
import '../models/resident_model.dart';
import '../services/visitor_service.dart';
import '../services/resident_service.dart';

class VisitorProvider extends ChangeNotifier {
  final VisitorService _visitorService = VisitorService();
  final ResidentService _residentService = ResidentService();
  
  List<VisitorModel> _visitors = [];
  List<VisitorModel> _allResidentVisitors = []; 
  List<VisitorModel> _activeVisitors = [];
  List<VisitorModel> _globalHistory = [];
  bool _isLoading = false;

  List<VisitorModel> get visitors => _visitors;
  List<VisitorModel> get allResidentVisitors => _allResidentVisitors;
  List<VisitorModel> get activeVisitors => _activeVisitors;
  List<VisitorModel> get globalHistory => _globalHistory;
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

  Future<void> loadActiveVisitors() async {
    _isLoading = true;
    notifyListeners();
    _activeVisitors = await _visitorService.getActiveVisitors();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadGlobalHistory(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();
    _globalHistory = await _visitorService.getGlobalVisitorHistory(start, end);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markExit(String visitorId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _visitorService.markVisitorExit(visitorId);
    if (success) {
      _activeVisitors.removeWhere((v) => v.id == visitorId);
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> registerVisitor(VisitorModel visitor, {File? idImage}) async {
    _isLoading = true;
    notifyListeners();

    final success = await _visitorService.registerVisitor(visitor, idImage: idImage);
    
    if (success) {
      await loadActiveVisitors();
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> addVisitor(VisitorModel visitor, String profileId) async {
    _isLoading = true;
    notifyListeners();
    
    String finalResidentId = visitor.residentId;

    if (finalResidentId.isEmpty) {
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
      carModel: visitor.carModel,
      carColor: visitor.carColor,
      carPlates: visitor.carPlates,
      entryAt: visitor.entryAt,
      exitAt: visitor.exitAt,
      guardId: visitor.guardId,
      idImageUrl: visitor.idImageUrl,
      comments: visitor.comments,
      unitNumber: visitor.unitNumber,
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
      _activeVisitors.removeWhere((v) => v.id == visitorId);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
