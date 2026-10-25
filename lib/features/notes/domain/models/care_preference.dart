import 'package:uuid/uuid.dart';

class CarePreference {
  final String id;
  final String title;
  final String category; // e.g. "Favorite Snacks", "Preferred Supplies", "Comfort Measures"
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  CarePreference({
    String? id,
    required this.title,
    required this.category,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  CarePreference copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarePreference(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CarePreference.fromMap(Map<String, dynamic> map) {
    return CarePreference(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      description: (map['description'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

