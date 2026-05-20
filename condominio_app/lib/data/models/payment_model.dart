class PaymentModel {
  final String id;
  final String residentId;
  final String? residentName; // Optional, for display
  final double amount;
  final String month;
  final String year;
  final String status;
  final String? receiptUrl;
  final DateTime createdAt;
  final String? description;

  PaymentModel({
    required this.id,
    required this.residentId,
    this.residentName,
    required this.amount,
    required this.month,
    required this.year,
    this.status = 'pending',
    this.receiptUrl,
    required this.createdAt,
    this.description,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Handling nested join structure: residents -> profiles -> name
    String? name = json['profiles']?['name']; // Fallback for old join
    if (json['residents']?['profiles'] != null) {
      name = json['residents']['profiles']['name'];
    }

    return PaymentModel(
      id: json['id']?.toString() ?? '',
      residentId: json['resident_id']?.toString() ?? '',
      residentName: name,
      amount: (json['amount'] ?? 0).toDouble(),
      month: json['month'] ?? '',
      year: json['year']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      receiptUrl: json['receipt_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'resident_id': residentId,
        'amount': amount,
        'month': month,
        'year': year,
        'status': status,
        'receipt_url': receiptUrl,
        'description': description,
      };

  PaymentModel copyWith({String? status}) {
    return PaymentModel(
      id: id,
      residentId: residentId,
      residentName: residentName,
      amount: amount,
      month: month,
      year: year,
      status: status ?? this.status,
      receiptUrl: receiptUrl,
      createdAt: createdAt,
      description: description,
    );
  }
}
