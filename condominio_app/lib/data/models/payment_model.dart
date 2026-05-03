class PaymentModel {
  final String id;
  final String residentId;
  final double amount;
  final DateTime date;
  final String status;
  final String concept;

  PaymentModel({
    required this.id,
    required this.residentId,
    required this.amount,
    required this.date,
    required this.status,
    required this.concept,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      residentId: json['residentId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      concept: json['concept'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'residentId': residentId,
        'amount': amount,
        'date': date.toIso8601String(),
        'status': status,
        'concept': concept,
      };
}