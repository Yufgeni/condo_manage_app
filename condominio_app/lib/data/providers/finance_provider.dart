import 'package:flutter/material.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';

class FinanceProvider extends ChangeNotifier {
  final List<IncomeModel> _incomes = [];
  final List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<IncomeModel> get incomes => _incomes;
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  final List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final List<String> years = List.generate(27, (index) => (2024 + index).toString());

  final List<String> expenseConcepts = [
    'Electricidad',
    'Jardinería',
    'Seguridad',
    'Limpieza',
    'Mantenimiento Elevadores',
    'Agua',
    'Otros'
  ];

  final List<String> incomeConcepts = [
    'Cuota mensual',
    'Multa',
    'Uso de amenidades',
    'Otros'
  ];

  Future<bool> registerIncome(IncomeModel income) async {
    _isLoading = true;
    notifyListeners();

    // Simular retraso de red o base de datos
    await Future.delayed(const Duration(seconds: 1));

    _incomes.add(income);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> registerExpense(ExpenseModel expense) async {
    _isLoading = true;
    notifyListeners();

    // Simular retraso
    await Future.delayed(const Duration(seconds: 1));

    _expenses.add(expense);

    _isLoading = false;
    notifyListeners();
    return true;
  }
}