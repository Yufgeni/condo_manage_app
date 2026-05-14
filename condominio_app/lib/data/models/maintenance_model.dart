class MaintenanceModel {
  final String id;
  final String concept;
  final double amount;
  final DateTime date;

  MaintenanceModel({
    required this.id,
    required this.concept,
    required this.amount,
    required this.date,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] ?? '',
      concept: json['concept'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'concept': concept,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}