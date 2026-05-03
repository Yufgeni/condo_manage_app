class GuardModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String shift;
  final bool isOnDuty;
  final String? photoUrl;

  GuardModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.shift,
    this.isOnDuty = false,
    this.photoUrl,
  });

  factory GuardModel.fromJson(Map<String, dynamic> json) {
    return GuardModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      shift: json['shift'] ?? '',
      isOnDuty: json['isOnDuty'] ?? false,
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'shift': shift,
        'isOnDuty': isOnDuty,
        'photoUrl': photoUrl,
      };
}