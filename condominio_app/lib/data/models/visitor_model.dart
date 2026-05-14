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
      id: json['id'] ?? '',
      residentId: json['residentId'] ?? '',
      name: json['name'] ?? '',
      carBrand: json['carBrand'] ?? '',
      carColor: json['carColor'] ?? '',
      carPlates: json['carPlates'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'residentId': residentId,
        'name': name,
        'carBrand': carBrand,
        'carColor': carColor,
        'carPlates': carPlates,
        'date': date.toIso8601String(),
      };
}