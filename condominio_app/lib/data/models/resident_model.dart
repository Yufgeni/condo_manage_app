class ResidentModel {
  final String id;
  final String profileId;
  final String name;
  final String email;
  final String phone;
  final String unitNumber;
  final List<CarInfo> cars;
  final String? photoUrl;

  ResidentModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.email,
    required this.phone,
    required this.unitNumber,
    this.cars = const [],
    this.photoUrl,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      unitNumber: json['unit_number'] ?? '',
      cars: (json['vehicles'] as List?)
              ?.map((c) => CarInfo.fromJson(c))
              .toList() ??
          [],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_id': profileId,
        'name': name,
        'email': email,
        'phone': phone,
        'unit_number': unitNumber,
        'cars': cars.map((c) => c.toJson()).toList(),
        'photoUrl': photoUrl,
      };

  ResidentModel copyWith({
    String? phone,
    String? unitNumber,
    List<CarInfo>? cars,
    String? photoUrl,
  }) {
    return ResidentModel(
      id: id,
      profileId: profileId,
      name: name,
      email: email,
      phone: phone ?? this.phone,
      unitNumber: unitNumber ?? this.unitNumber,
      cars: cars ?? this.cars,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class CarInfo {
  final String? id;
  final String brand;
  final String year;
  final String color;
  final String plates;

  CarInfo({
    this.id,
    required this.brand,
    required this.year,
    required this.color,
    required this.plates,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['id']?.toString(),
      brand: json['brand'] ?? '',
      year: json['model_year']?.toString() ?? json['year']?.toString() ?? '',
      color: json['color'] ?? '',
      plates: json['plates'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'brand': brand,
        'model_year': year,
        'color': color,
        'plates': plates,
      };
}