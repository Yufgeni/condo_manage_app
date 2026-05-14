class ResidentModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String unitNumber;
  final List<CarInfo> cars;
  final String? photoUrl;

  ResidentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.unitNumber,
    this.cars = const [],
    this.photoUrl,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      unitNumber: json['unitNumber'] ?? '',
      cars: (json['cars'] as List?)?.map((c) => CarInfo.fromJson(c)).toList() ??
          (json['car'] != null ? [CarInfo.fromJson(json['car'])] : []),
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'unitNumber': unitNumber,
        'cars': cars.map((c) => c.toJson()).toList(),
        'photoUrl': photoUrl,
      };

  ResidentModel copyWith({
    String? phone,
    List<CarInfo>? cars,
    String? photoUrl,
  }) {
    return ResidentModel(
      id: id,
      userId: userId,
      name: name,
      email: email,
      phone: phone ?? this.phone,
      unitNumber: unitNumber,
      cars: cars ?? this.cars,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class CarInfo {
  final String brand;
  final String year;
  final String color;
  final String plates;

  CarInfo({
    required this.brand,
    required this.year,
    required this.color,
    required this.plates,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      brand: json['brand'] ?? '',
      year: json['year'] ?? '',
      color: json['color'] ?? '',
      plates: json['plates'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'year': year,
        'color': color,
        'plates': plates,
      };
}