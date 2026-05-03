class ResidentModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String unitNumber;
  final CarInfo? car;
  final String? photoUrl;

  ResidentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.unitNumber,
    this.car,
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
      car: json['car'] != null ? CarInfo.fromJson(json['car']) : null,
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
        'car': car?.toJson(),
        'photoUrl': photoUrl,
      };

  ResidentModel copyWith({
    String? phone,
    CarInfo? car,
    String? photoUrl,
  }) {
    return ResidentModel(
      id: id,
      userId: userId,
      name: name,
      email: email,
      phone: phone ?? this.phone,
      unitNumber: unitNumber,
      car: car ?? this.car,
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