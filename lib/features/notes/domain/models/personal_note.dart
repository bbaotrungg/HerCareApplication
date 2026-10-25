import 'package:uuid/uuid.dart';

class PersonalNote {
  final String id;
  final String title;
  final String content;
  final String category; // e.g. "General", "Care Reminder", "Shared Preference", "Gift Idea"
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonalNote({
    String? id,
    required this.title,
    required this.content,
    this.category = 'General',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  PersonalNote copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PersonalNote.fromMap(Map<String, dynamic> map) {
    return PersonalNote(
      id: map['id'] as String,
      title: map['title'] as String,
      content: (map['content'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'General',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

