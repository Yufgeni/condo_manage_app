class PaymentModel {
  final String id;
  final String residentId;
  final String? residentName; // Optional, for display
  final String? residentPhone; // Added for WhatsApp
  final double amount;
  final String month;
  final String year;
  final String status;
  final String? paymentMethod; // Added
  final String? receiptUrl;
  final DateTime createdAt;
  final String? description;

  PaymentModel({
    required this.id,
    required this.residentId,
    this.residentName,
    this.residentPhone,
    required this.amount,
    required this.month,
    required this.year,
    this.status = 'pending',
    this.paymentMethod,
    this.receiptUrl,
    required this.createdAt,
    this.description,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Handling nested join structure: residents -> profiles -> name
    String? name = json['profiles']?['name']; // Fallback for old join
    String? lastName = json['profiles']?['last_name'];
    String? phone = json['profiles']?['phone'];
    if (json['residents']?['profiles'] != null) {
      name = json['residents']['profiles']['name'];
      lastName = json['residents']['profiles']['last_name'];
      phone = json['residents']['profiles']['phone'];
    }

    final fullName = (name != null && lastName != null) 
        ? '$name $lastName' 
        : (name ?? '');

    return PaymentModel(
      id: json['id']?.toString() ?? '',
      residentId: json['resident_id']?.toString() ?? '',
      residentName: fullName.isNotEmpty ? fullName : null,
      residentPhone: phone,
      amount: (json['amount'] ?? 0).toDouble(),
      month: json['month'] ?? '',
      year: json['year']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
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
        'payment_method': paymentMethod,
        'receipt_url': receiptUrl,
        'description': description,
      };

  PaymentModel copyWith({String? status, String? residentPhone, String? paymentMethod}) {
    return PaymentModel(
      id: id,
      residentId: residentId,
      residentName: residentName,
      residentPhone: residentPhone ?? this.residentPhone,
      amount: amount,
      month: month,
      year: year,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl,
      createdAt: createdAt,
      description: description,
    );
  }
}
