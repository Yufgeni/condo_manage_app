class VisitorModel {
  final String id;
  final String residentId;
  final String name;
  final String carBrand;
  final String carColor;
  final String carPlates;
  final DateTime date;

  VisitorModel({
    required this.id,
    required this.residentId,
    required this.name,
    required this.carBrand,
    required this.carColor,
    required this.carPlates,
    required this.date,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id']?.toString() ?? '',
      residentId: (json['resident_id'] ?? json['residentId'] ?? '').toString(),
      name: json['name'] ?? '',
      carBrand: (json['car_brand'] ?? json['carBrand'] ?? '').toString(),
      carColor: (json['car_color'] ?? json['carColor'] ?? '').toString(),
      carPlates: (json['car_plates'] ?? json['carPlates'] ?? '').toString(),
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : (json['entry_at'] != null ? DateTime.parse(json['entry_at']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
        'resident_id': residentId,
        'name': name,
        'car_brand': carBrand,
        'car_color': carColor,
        'car_plates': carPlates,
        'entry_at': date.toIso8601String(),
      };
}