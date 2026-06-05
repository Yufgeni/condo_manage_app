import 'package:flutter/material.dart';
import 'dart:io';
import '../models/payment_model.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../services/finance_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceService _financeService = FinanceService();

  List<PaymentModel> _pendingPayments = [];
  List<PaymentModel> _residentPayments = [];
  List<PaymentModel> _monthlyIncomes = [];
  List<ExpenseModel> _monthlyExpenses = [];
  List<String> _incomeConcepts = [];
  List<String> _expenseConcepts = [];
  double _previousBalance = 0;
  bool _isLoading = false;

  List<PaymentModel> get pendingPayments => _pendingPayments;
  List<PaymentModel> get residentPayments => _residentPayments;
  List<PaymentModel> get monthlyIncomes => _monthlyIncomes;
  List<ExpenseModel> get monthlyExpenses => _monthlyExpenses;
  List<String> get incomeConcepts => _incomeConcepts;
  List<String> get expenseConcepts => _expenseConcepts;
  double get previousBalance => _previousBalance;
  bool get isLoading => _isLoading;

  final List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final List<String> years = List.generate(27, (index) => (2024 + index).toString());

  Future<void> fetchConcepts() async {
    _isLoading = true;
    notifyListeners();
    _incomeConcepts = await _financeService.getConcepts('income');
    _expenseConcepts = await _financeService.getConcepts('expense');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addConcept(String name, String type) async {
    final success = await _financeService.addConcept(name, type);
    if (success) {
      await fetchConcepts();
    }
  }

  Future<bool> deleteConcept(String name, String type) async {
    final success = await _financeService.deleteConcept(name, type);
    if (success) {
      await fetchConcepts();
    }
    return success;
  }

  Future<void> fetchPendingPayments() async {
    _isLoading = true;
    notifyListeners();
    _pendingPayments = await _financeService.getAllPendingPayments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchResidentPayments(String residentId) async {
    _isLoading = true;
    notifyListeners();
    _residentPayments = await _financeService.getPaymentsByResident(residentId);
    _isLoading = false;
    notifyListeners();
  }

  Future<PaymentModel?> registerPayment({
    required String residentId,
    required double amount,
    required String month,
    required String year,
    File? image,
    String? description,
    bool isAdminRegistration = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    final payment = PaymentModel(
      id: '',
      residentId: residentId,
      amount: amount,
      month: month,
      year: year,
      status: isAdminRegistration ? 'paid' : 'pending',
      createdAt: DateTime.now(),
      description: description,
    );

    final PaymentModel? createdPayment = await _financeService.uploadPayment(payment, image);
    
    _isLoading = false;
    notifyListeners();
    return createdPayment;
  }

  Future<PaymentModel?> registerIncome(IncomeModel income) async {
    return await registerPayment(
      residentId: income.residentId,
      amount: income.amount,
      month: income.month,
      year: income.year,
      description: income.concept,
      isAdminRegistration: true,
    );
  }

  Future<bool> approvePayment(String paymentId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _financeService.approvePayment(paymentId);
    if (success) {
      _pendingPayments.removeWhere((p) => p.id == paymentId);
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> registerExpense(ExpenseModel expense) async {
    _isLoading = true;
    notifyListeners();
    final success = await _financeService.createExpense(expense);
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteExpense(String expenseId, String month, String year) async {
    _isLoading = true;
    notifyListeners();
    final success = await _financeService.deleteExpense(expenseId);
    if (success) {
      await fetchMonthlyData(month, year);
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteIncome(String paymentId, String month, String year) async {
    _isLoading = true;
    notifyListeners();
    final success = await _financeService.deletePayment(paymentId);
    if (success) {
      await fetchMonthlyData(month, year);
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> fetchMonthlyData(String month, String year) async {
    _isLoading = true;
    notifyListeners();
    final yearInt = int.tryParse(year) ?? DateTime.now().year;
    _monthlyIncomes = await _financeService.getMonthlyIncomes(month, yearInt);
    _monthlyExpenses = await _financeService.getMonthlyExpenses(month, yearInt);
    _previousBalance = await _financeService.getPreviousBalance(month, yearInt);
    _isLoading = false;
    notifyListeners();
  }
}
