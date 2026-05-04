import 'dart:io';

class ReportModel {
  final String id;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final String? authorId;

  ReportModel({
    required this.id,
    required this.description,
    this.imageUrl,
    required this.date,
    this.authorId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'imageUrl': imageUrl,
        'date': date.toIso8601String(),
        'authorId': authorId,
      };

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      authorId: json['authorId'],
    );
  }
}