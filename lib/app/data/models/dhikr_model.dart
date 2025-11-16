import 'package:hive/hive.dart';

part 'dhikr_model.g.dart';

@HiveType(typeId: 0)
class DhikrModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String arabicText;

  @HiveField(2)
  String persianTranslation;

  @HiveField(3)
  String meaning;

  @HiveField(4)
  String category;

  @HiveField(5)
  int defaultCount;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  String? audioPath;

  @HiveField(10)
  List<String> tags;

  @HiveField(11)
  int priority;

  @HiveField(12)
  bool isCustom;

  @HiveField(13)
  int? overallGoal;

  DhikrModel({
    required this.id,
    required this.arabicText,
    required this.persianTranslation,
    required this.meaning,
    required this.category,
    this.defaultCount = 33,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.audioPath,
    this.tags = const [],
    this.priority = 0,
    this.isCustom = false,
    this.overallGoal,
  });

  // کپی با تغییرات
  DhikrModel copyWith({
    String? id,
    String? arabicText,
    String? persianTranslation,
    String? meaning,
    String? category,
    int? defaultCount,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? audioPath,
    List<String>? tags,
    int? priority,
    bool? isCustom,
    int? overallGoal,
  }) {
    return DhikrModel(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      persianTranslation: persianTranslation ?? this.persianTranslation,
      meaning: meaning ?? this.meaning,
      category: category ?? this.category,
      defaultCount: defaultCount ?? this.defaultCount,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      audioPath: audioPath ?? this.audioPath,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      isCustom: isCustom ?? this.isCustom,
      overallGoal: overallGoal ?? this.overallGoal,
    );
  }

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'arabicText': arabicText,
      'persianTranslation': persianTranslation,
      'meaning': meaning,
      'category': category,
      'defaultCount': defaultCount,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'audioPath': audioPath,
      'tags': tags,
      'priority': priority,
      'isCustom': isCustom,
      'overallGoal': overallGoal,
    };
  }

  // ایجاد از Map
  factory DhikrModel.fromMap(Map<String, dynamic> map) {
    return DhikrModel(
      id: (map['id'] ?? '') as String,
      arabicText: (map['arabicText'] ?? '') as String,
      persianTranslation: (map['persianTranslation'] ?? '') as String,
      meaning: (map['meaning'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      defaultCount: (map['defaultCount'] as int?) ?? 33,
      isFavorite: (map['isFavorite'] as bool?) ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      audioPath: map['audioPath'] as String?,
      tags: List<String>.from((map['tags'] as List?) ?? []),
      priority: (map['priority'] as int?) ?? 0,
      isCustom: (map['isCustom'] as bool?) ?? false,
      overallGoal: map['overallGoal'] as int?,
    );
  }

  @override
  String toString() {
    return 'DhikrModel(id: $id, arabicText: $arabicText, persianTranslation: $persianTranslation, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DhikrModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}