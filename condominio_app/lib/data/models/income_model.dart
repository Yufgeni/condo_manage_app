class IncomeModel {
  final String id;
  final String residentId;
  final String residentName;
  final String month;
  final String year;
  final String concept;
  final double amount;
  final DateTime date;

  IncomeModel({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.month,
    required this.year,
    required this.concept,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'residentId': residentId,
        'residentName': residentName,
        'month': month,
        'year': year,
        'concept': concept,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}