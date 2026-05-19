class ReportModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;
  final String createdBy;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.status = 'pending',
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'created_by': createdBy,
      };

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by']?.toString() ?? '',
    );
  }

  ReportModel copyWith({String? status}) {
    return ReportModel(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
