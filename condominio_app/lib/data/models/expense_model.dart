class ExpenseModel {
  final String id;
  final String month;
  final String year;
  final String concept;
  final double amount;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.month,
    required this.year,
    required this.concept,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'month': month,
        'year': year,
        'concept': concept,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}