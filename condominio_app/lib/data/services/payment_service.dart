import '../models/payment_model.dart';

class PaymentService {
  // Mock data - Replace with real API calls
  final List<PaymentModel> _mockPayments = [
    PaymentModel(
      id: '1',
      residentId: '2',
      amount: 1500.0,
      date: DateTime(2024, 1, 5),
      status: 'paid',
      concept: 'Cuota de mantenimiento Enero',
    ),
    PaymentModel(
      id: '2',
      residentId: '2',
      amount: 1500.0,
      date: DateTime(2024, 2, 3),
      status: 'paid',
      concept: 'Cuota de mantenimiento Febrero',
    ),
    PaymentModel(
      id: '3',
      residentId: '2',
      amount: 1500.0,
      date: DateTime(2024, 3, 1),
      status: 'pending',
      concept: 'Cuota de mantenimiento Marzo',
    ),
  ];

  Future<List<PaymentModel>> getPaymentsByResident(String residentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPayments.where((p) => p.residentId == residentId).toList();
  }

  Future<List<PaymentModel>> getAllPayments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPayments;
  }
}