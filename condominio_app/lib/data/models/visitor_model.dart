class VisitorModel {
  final String id;
  final String residentId;
  final String name;
  final String carBrand;
  final String carModel;
  final String carColor;
  final String carPlates;
  final DateTime entryAt;
  final DateTime? exitAt;
  final String? guardId;
  final String? guardName;
  final String? idImageUrl;
  final String? comments;
  final String? unitNumber;

  VisitorModel({
    required this.id,
    required this.residentId,
    required this.name,
    required this.carBrand,
    this.carModel = '',
    required this.carColor,
    required this.carPlates,
    required this.entryAt,
    this.exitAt,
    this.guardId,
    this.guardName,
    this.idImageUrl,
    this.comments,
    this.unitNumber,
  });

  bool get isActive => exitAt == null;

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id']?.toString() ?? '',
      residentId: (json['resident_id'] ?? json['residentId'] ?? '').toString(),
      name: json['name'] ?? '',
      carBrand: (json['car_brand'] ?? json['carBrand'] ?? '').toString(),
      carModel: (json['car_model'] ?? json['carModel'] ?? '').toString(),
      carColor: (json['car_color'] ?? json['carColor'] ?? '').toString(),
      carPlates: (json['car_plates'] ?? json['carPlates'] ?? '').toString(),
      entryAt: json['entry_at'] != null 
          ? DateTime.parse(json['entry_at']) 
          : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now()),
      exitAt: json['exit_at'] != null ? DateTime.parse(json['exit_at']) : null,
      guardId: json['guard_id']?.toString(),
      guardName: json['guard_name'] ?? json['guards']?['name']?.toString(),
      idImageUrl: json['id_image_url']?.toString(),
      comments: json['comments']?.toString(),
      unitNumber: json['unit_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'resident_id': residentId,
        'name': name,
        'car_brand': carBrand,
        'car_model': carModel,
        'car_color': carColor,
        'car_plates': carPlates,
        'entry_at': entryAt.toIso8601String(),
        'exit_at': exitAt?.toIso8601String(),
        'guard_id': guardId,
        'id_image_url': idImageUrl,
        'comments': comments,
        'unit_number': unitNumber,
      };
}
