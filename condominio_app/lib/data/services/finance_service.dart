import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';
import '../models/expense_model.dart';

class FinanceService {
  final _supabase = Supabase.instance.client;

  // --- PAGOS (Payments) ---

  Future<List<PaymentModel>> getPaymentsByResident(String residentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*, profiles:resident_id(name)')
          .eq('resident_id', residentId)
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => PaymentModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener pagos del residente: $e');
      return [];
    }
  }

  Future<List<PaymentModel>> getAllPendingPayments() async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*, profiles:resident_id(name)')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => PaymentModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener pagos pendientes: $e');
      return [];
    }
  }

  Future<bool> uploadPayment(PaymentModel payment, File? imageFile) async {
    try {
      String? receiptUrl;

      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${payment.residentId}.jpg';
        final path = 'receipts/$fileName';
        await _supabase.storage.from('payment-receipts').upload(path, imageFile);
        receiptUrl = _supabase.storage.from('payment-receipts').getPublicUrl(path);
      }

      await _supabase.from('payments').insert({
        'resident_id': payment.residentId,
        'amount': payment.amount,
        'month': payment.month,
        'year': int.tryParse(payment.year) ?? DateTime.now().year,
        'status': payment.status,
        'receipt_url': receiptUrl,
        'description': payment.description,
      });
      
      return true;
    } catch (e) {
      print('Error al registrar pago: $e');
      return false;
    }
  }

  Future<bool> approvePayment(String paymentId) async {
    try {
      await _supabase
          .from('payments')
          .update({'status': 'paid'})
          .eq('id', paymentId);
      return true;
    } catch (e) {
      print('Error al aprobar pago: $e');
      return false;
    }
  }

  // --- EGRESOS (Expenses) ---

  Future<bool> createExpense(ExpenseModel expense) async {
    try {
      await _supabase.from('expenses').insert(expense.toJson());
      return true;
    } catch (e) {
      print('Error al crear egreso: $e');
      return false;
    }
  }

  Future<List<ExpenseModel>> getMonthlyExpenses(String month, int year) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('month', month)
          .eq('year', year);
      
      return (response as List).map((data) => ExpenseModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener egresos mensuales: $e');
      return [];
    }
  }

  // --- BALANCES (Reports) ---

  Future<List<PaymentModel>> getMonthlyIncomes(String month, int year) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*, profiles:resident_id(name)')
          .eq('month', month)
          .eq('year', year)
          .eq('status', 'paid');
      
      return (response as List).map((data) => PaymentModel.fromJson(data)).toList();
    } catch (e) {
      print('Error al obtener ingresos mensuales: $e');
      return [];
    }
  }
}
