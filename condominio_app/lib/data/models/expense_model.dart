class ExpenseModel {
  final String id;
  final String concept;
  final String? description;
  final double amount;
  final String month;
  final int year;
  final DateTime? expenseDate;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.concept,
    this.description,
    required this.amount,
    required this.month,
    required this.year,
    this.expenseDate,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      concept: json['concept'] ?? '',
      description: json['description'],
      amount: (json['amount'] ?? 0).toDouble(),
      month: json['month'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      expenseDate: json['expense_date'] != null ? DateTime.parse(json['expense_date']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'concept': concept,
        'description': description,
        'amount': amount,
        'month': month,
        'year': year,
        'expense_date': expenseDate?.toIso8601String().split('T')[0],
      };
}
