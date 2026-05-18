import 'package:flutter/material.dart';
import '../models/resident_model.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../services/resident_service.dart';

class ResidentProvider extends ChangeNotifier {
  final ResidentService _residentService = ResidentService();
  final PaymentService _paymentService = PaymentService();

  ResidentModel? _resident;
  List<PaymentModel> _payments = [];
  bool _isLoading = false;

  ResidentModel? get resident => _resident;
  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;

  Future<void> loadResidentData(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    _resident = await _residentService.getResidentByUserId(userId);
    if (_resident != null) {
      _payments = await _paymentService.getPaymentsByResident(_resident!.id);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updatePhone(String phone) async {
    if (_resident == null) return false;
    _isLoading = true;
    notifyListeners();

    final success = await _residentService.updateProfilePhone(_resident!.profileId, phone);
    if (success) {
      _resident = _resident!.copyWith(phone: phone);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> addVehicle(CarInfo car) async {
    if (_resident == null) return false;
    _isLoading = true;
    notifyListeners();

    final success = await _residentService.addVehicle(_resident!.id, car);
    if (success) {
      // Recargar datos para obtener el nuevo ID del vehículo
      _resident = await _residentService.getResidentByUserId(_resident!.profileId);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateVehicle(CarInfo car) async {
    if (_resident == null) return false;
    _isLoading = true;
    notifyListeners();

    final success = await _residentService.updateVehicle(car);
    if (success) {
      final index = _resident!.cars.indexWhere((c) => c.id == car.id);
      if (index != -1) {
        final newCars = List<CarInfo>.from(_resident!.cars);
        newCars[index] = car;
        _resident = _resident!.copyWith(cars: newCars);
      }
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
  
  // Listado para el Administrador
  List<ResidentModel> _allResidents = [];
  List<ResidentModel> get allResidents => _allResidents;

  Future<void> fetchAllResidents() async {
    _isLoading = true;
    notifyListeners();
    _allResidents = await _residentService.getAllResidents();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addResident(ResidentModel resident) async {
    _isLoading = true;
    notifyListeners();
    // Para compilar, agregamos este stub. 
    // En una implementación real, esto llamaría a un servicio.
    _allResidents.add(resident);
    _isLoading = false;
    notifyListeners();
  }
}