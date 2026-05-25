class UserModel {
  final String id;
  final String email;
  final String name;
  final String lastName;
  final String role;
  final String? photoUrl;
  final bool isOnDuty;
  final String? phone;
  final String? unitNumber;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.role,
    this.photoUrl,
    this.isOnDuty = false,
    this.phone,
    this.unitNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? '',
      photoUrl: json['photo_url'],
      isOnDuty: json['is_on_duty'] ?? false,
      phone: json['phone'],
      unitNumber: json['residents']?['unit_number']?.toString() ?? json['unit_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'last_name': lastName,
        'role': role,
        'photo_url': photoUrl,
        'is_on_duty': isOnDuty,
        'phone': phone,
        'unit_number': unitNumber,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? lastName,
    String? role,
    String? photoUrl,
    bool? isOnDuty,
    String? phone,
    String? unitNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      phone: phone ?? this.phone,
      unitNumber: unitNumber ?? this.unitNumber,
    );
  }

  String get fullName => '$name $lastName';

  String get shiftName {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) {
      return 'Matutino';
    } else if (hour >= 12 && hour < 18) {
      return 'Vespertino';
    } else {
      return 'Nocturno';
    }
  }
}