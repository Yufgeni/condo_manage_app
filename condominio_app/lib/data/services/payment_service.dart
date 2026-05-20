import '../models/payment_model.dart';

class PaymentService {
  // Mock data - Updated to match current PaymentModel
  final List<PaymentModel> _mockPayments = [
    PaymentModel(
      id: '1',
      residentId: '2',
      amount: 1500.0,
      month: 'Enero',
      year: '2024',
      status: 'paid',
      description: 'Cuota de mantenimiento Enero',
      createdAt: DateTime(2024, 1, 5),
    ),
    PaymentModel(
      id: '2',
      residentId: '2',
      amount: 1500.0,
      month: 'Febrero',
      year: '2024',
      status: 'paid',
      description: 'Cuota de mantenimiento Febrero',
      createdAt: DateTime(2024, 2, 3),
    ),
    PaymentModel(
      id: '3',
      residentId: '2',
      amount: 1500.0,
      month: 'Marzo',
      year: '2024',
      status: 'pending',
      description: 'Cuota de mantenimiento Marzo',
      createdAt: DateTime(2024, 3, 1),
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
