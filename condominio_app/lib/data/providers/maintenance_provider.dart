import 'package:flutter/material.dart';
import '../models/maintenance_model.dart';

class MaintenanceProvider extends ChangeNotifier {
  final List<MaintenanceModel> _maintenanceRecords = [
    MaintenanceModel(
      id: '1',
      concept: 'Pago a jardinero Jose Luis Rodriguez',
      amount: 4000,
      date: DateTime(2026, 5, 13),
    ),
    MaintenanceModel(
      id: '2',
      concept: 'Pago a CFE : alumbrado',
      amount: 6000,
      date: DateTime(2026, 5, 13),
    ),
    MaintenanceModel(
      id: '3',
      concept: 'Pago a instalacion de camaras',
      amount: 3000,
      date: DateTime(2026, 5, 13),
    ),
  ];

  List<MaintenanceModel> get maintenanceRecords => _maintenanceRecords;

  void addRecord(MaintenanceModel record) {
    _maintenanceRecords.insert(0, record);
    notifyListeners();
  }
}