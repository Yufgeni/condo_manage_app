import 'package:flutter_test/flutter_test.dart';
import 'package:condominio_app/data/models/payment_model.dart';
import 'package:condominio_app/data/models/income_model.dart';

void main() {
  group('PaymentModel Tests', () {
    test('toJson includes payment_method', () {
      final payment = PaymentModel(
        id: '1',
        residentId: 'res1',
        amount: 100.0,
        month: 'Enero',
        year: '2024',
        paymentMethod: 'Efectivo',
        createdAt: DateTime.now(),
      );

      final json = payment.toJson();
      expect(json['payment_method'], 'Efectivo');
    });

    test('fromJson reads payment_method', () {
      final json = {
        'id': '1',
        'resident_id': 'res1',
        'amount': 100.0,
        'month': 'Enero',
        'year': 2024,
        'status': 'paid',
        'payment_method': 'Transferencia',
        'created_at': DateTime.now().toIso8601String(),
      };

      final payment = PaymentModel.fromJson(json);
      expect(payment.paymentMethod, 'Transferencia');
    });
  });

  group('IncomeModel Tests', () {
    test('toJson includes paymentMethod', () {
      final income = IncomeModel(
        id: '1',
        residentId: 'res1',
        residentName: 'Juan',
        month: 'Enero',
        year: '2024',
        concept: 'Mantenimiento',
        paymentMethod: 'Efectivo',
        amount: 100.0,
        date: DateTime.now(),
      );

      final json = income.toJson();
      expect(json['paymentMethod'], 'Efectivo');
    });
  });
}
