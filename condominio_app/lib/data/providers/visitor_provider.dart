import 'package:flutter/material.dart';
import '../models/visitor_model.dart';

class VisitorProvider extends ChangeNotifier {
  final List<VisitorModel> _visitors = [
    VisitorModel(
      id: '1',
      residentId: '2',
      name: 'Pedro Picapiedra',
      carBrand: 'Troncomovil',
      carColor: 'Madera',
      carPlates: 'P-001',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    VisitorModel(
      id: '2',
      residentId: '2',
      name: 'Pablo Marmol',
      carBrand: 'Honda',
      carColor: 'Gris',
      carPlates: 'XYZ-789',
      date: DateTime.now(),
    ),
  ];

  List<VisitorModel> get visitors => _visitors;

  List<VisitorModel> get todayVisitors {
    final now = DateTime.now();
    return _visitors.where((v) => 
      v.date.year == now.year && 
      v.date.month == now.month && 
      v.date.day == now.day
    ).toList();
  }

  List<VisitorModel> get pastVisitors {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _visitors.where((v) => v.date.isBefore(today)).toList();
  }

  void addVisitor(VisitorModel visitor) {
    _visitors.insert(0, visitor);
    notifyListeners();
  }

  void removeVisitor(String id) {
    _visitors.removeWhere((v) => v.id == id);
    notifyListeners();
  }
}