import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/expense_model.dart';

class FinanceService {
  final _supabase = Supabase.instance.client;

  Future<UserModel?> getTreasurerProfile() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'admin')
          .eq('is_treasurer', true)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting treasurer profile: $e');
      return null;
    }
  }

  // --- PAGOS (Payments) ---

  Future<List<PaymentModel>> getPaymentsByResident(String residentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('resident_id', residentId)
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => PaymentModel.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PaymentModel>> getAllPendingPayments() async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*, residents(profiles(name, last_name, phone))')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => PaymentModel.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PaymentModel?> uploadPayment(PaymentModel payment, File? imageFile) async {
    try {
      String? receiptUrl;

      // Ensure resident_id is valid UUID. 
      // Sometimes we receive profile_id from admin residents.
      String residentId = payment.residentId;
      
      // Check if it's already a resident entry or if we need to create/find one
      Map<String, dynamic>? resCheck;
      if (residentId.isNotEmpty) {
        resCheck = await _supabase
            .from('residents')
            .select('id')
            .eq('id', residentId)
            .maybeSingle();
      }
      
      if (resCheck == null) {
        // Might be a profile_id, check in residents table
        final profCheck = await _supabase
            .from('residents')
            .select('id')
            .eq('profile_id', residentId)
            .maybeSingle();
        
        if (profCheck != null) {
          residentId = profCheck['id'].toString();
        } else {
          // It's a live-in admin not yet in residents table, or a bad ID.
          // Try to create resident entry for this profile_id
          try {
            final newRes = await _supabase.from('residents').insert({
              'profile_id': residentId,
              'unit_number': 'S/N',
            }).select('id').single();
            residentId = newRes['id'].toString();
          } catch (e) {
             debugPrint('Could not map profile_id $residentId to a resident_id: $e');
             return null;
          }
        }
      }

      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${residentId}.jpg';
        final path = 'receipts/$fileName';
        await _supabase.storage.from('payment-receipts').upload(path, imageFile);
        receiptUrl = _supabase.storage.from('payment-receipts').getPublicUrl(path);
      }

      final response = await _supabase.from('payments').insert({
        'resident_id': residentId,
        'amount': payment.amount,
        'month': payment.month,
        'year': int.tryParse(payment.year) ?? DateTime.now().year,
        'status': payment.status,
        'receipt_url': receiptUrl,
        'description': payment.description,
      }).select('*, residents(profiles(name, last_name, phone))').single();
      
      return PaymentModel.fromJson(response);
    } catch (e) {
      debugPrint('Error uploading payment: $e');
      return null;
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
      return false;
    }
  }

  // --- EGRESOS (Expenses) ---

  Future<bool> createExpense(ExpenseModel expense) async {
    try {
      await _supabase.from('expenses').insert(expense.toJson());
      return true;
    } catch (e) {
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
      return [];
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _supabase.from('expenses').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- BALANCES (Reports) ---

  Future<List<PaymentModel>> getMonthlyIncomes(String month, int year) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*, residents(profiles(name, last_name, phone))')
          .eq('month', month)
          .eq('year', year)
          .eq('status', 'paid');
      
      return (response as List).map((data) => PaymentModel.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> deletePayment(String id) async {
    try {
      await _supabase.from('payments').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- CONCEPTOS (Concepts) ---

  Future<List<String>> getConcepts(String type) async {
    try {
      final response = await _supabase
          .from('finance_concepts')
          .select('name')
          .eq('type', type)
          .order('name');
      
      return (response as List).map((c) => c['name'] as String).toList();
    } catch (e) {
      // Si la tabla no existe o hay error, fallamos silenciosamente devolviendo lista vacía
      // para que el Provider use los valores por defecto.
      debugPrint('Nota: La tabla finance_concepts no respondió: $e');
      return [];
    }
  }

  Future<bool> addConcept(String name, String type) async {
    try {
      await _supabase.from('finance_concepts').upsert({
        'name': name,
        'type': type,
      });
      return true;
    } catch (e) {
      debugPrint('Error añadiendo concepto: $e. Asegúrate de que la tabla finance_concepts existe.');
      return false;
    }
  }

  Future<bool> deleteConcept(String name, String type) async {
    try {
      await _supabase
          .from('finance_concepts')
          .delete()
          .eq('name', name)
          .eq('type', type);
      return true;
    } catch (e) {
      debugPrint('Error eliminando concepto: $e');
      return false;
    }
  }

  Future<double> getPreviousBalance(String month, int year) async {
    try {
      // Definimos el orden cronológico de los meses para el filtro
      final monthsList = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      final currentMonthIndex = monthsList.indexOf(month);

      // 1. Obtener todos los ingresos pagados previos
      final paymentsResponse = await _supabase
          .from('payments')
          .select('amount, month, year')
          .eq('status', 'paid');
      
      double totalIncomes = 0;
      for (var p in paymentsResponse as List) {
        final pYear = p['year'] as int;
        final pMonthIndex = monthsList.indexOf(p['month']);
        
        if (pYear < year || (pYear == year && pMonthIndex < currentMonthIndex)) {
          totalIncomes += (p['amount'] as num).toDouble();
        }
      }

      // 2. Obtener todos los egresos previos
      final expensesResponse = await _supabase
          .from('expenses')
          .select('amount, month, year');

      double totalExpenses = 0;
      for (var e in expensesResponse as List) {
        final eYear = e['year'] as int;
        final eMonthIndex = monthsList.indexOf(e['month']);

        if (eYear < year || (eYear == year && eMonthIndex < currentMonthIndex)) {
          totalExpenses += (e['amount'] as num).toDouble();
        }
      }

      return totalIncomes - totalExpenses;
    } catch (e) {
      debugPrint('Error calculating previous balance: $e');
      return 0.0;
    }
  }
}
