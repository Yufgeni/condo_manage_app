import 'package:flutter/material.dart';
import '../models/resident_model.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class ResidentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  ResidentModel? _resident;
  List<PaymentModel> _payments = [];
  bool _isLoading = false;

  ResidentModel? get resident => _resident;
  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;

  // Mock resident data
  final ResidentModel _mockResident = ResidentModel(
    id: '2',
    userId: '2',
    name: 'Juan Pérez',
    email: 'residente@condominio.com',
    phone: '5512345678',
    unitNumber: 'A-101',
    car: CarInfo(
      brand: 'Toyota',
      year: '2020',
      color: 'Blanco',
      plates: 'ABC-1234',
    ),
  );

  Future<void> loadResidentData(String userId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _resident = _mockResident;
    _payments = await _paymentService.getPaymentsByResident(_mockResident.id);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String phone,
    required CarInfo car,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _resident = _resident?.copyWith(phone: phone, car: car);
    _isLoading = false;
    notifyListeners();
    return true;
  }
}