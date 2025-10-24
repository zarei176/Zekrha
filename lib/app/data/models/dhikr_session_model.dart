import 'package:hive/hive.dart';

part 'dhikr_session_model.g.dart';

@HiveType(typeId: 1)
class DhikrSessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String dhikrId;

  @HiveField(2)
  int targetCount;

  @HiveField(3)
  int currentCount;

  @HiveField(4)
  DateTime startTime;

  @HiveField(5)
  DateTime? endTime;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  Duration duration;

  @HiveField(8)
  DateTime date;

  @HiveField(9)
  List<DateTime> clickTimes;

  @HiveField(10)
  Map<String, dynamic> metadata;

  DhikrSessionModel({
    required this.id,
    required this.dhikrId,
    required this.targetCount,
    this.currentCount = 0,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.duration = Duration.zero,
    required this.date,
    this.clickTimes = const [],
    this.metadata = const {},
  });

  // کپی با تغییرات
  DhikrSessionModel copyWith({
    String? id,
    String? dhikrId,
    int? targetCount,
    int? currentCount,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    Duration? duration,
    DateTime? date,
    List<DateTime>? clickTimes,
    Map<String, dynamic>? metadata,
  }) {
    return DhikrSessionModel(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      clickTimes: clickTimes ?? this.clickTimes,
      metadata: metadata ?? this.metadata,
    );
  }

  // درصد پیشرفت
  double get progressPercentage {
    if (targetCount == 0) return 0.0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  // باقی‌مانده تا هدف
  int get remainingCount {
    return (targetCount - currentCount).clamp(0, targetCount);
  }

  // میانگین سرعت (کلیک در دقیقه)
  double get averageSpeed {
    if (clickTimes.isEmpty || duration.inSeconds == 0) return 0.0;
    return (clickTimes.length / duration.inMinutes).clamp(0.0, double.infinity);
  }

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dhikrId': dhikrId,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'duration': duration.inMilliseconds,
      'date': date.toIso8601String(),
      'clickTimes': clickTimes.map((time) => time.toIso8601String()).toList(),
      'metadata': metadata,
    };
  }

  // ایجاد از Map
  factory DhikrSessionModel.fromMap(Map<String, dynamic> map) {
    return DhikrSessionModel(
      id: (map['id'] ?? '') as String,
      dhikrId: (map['dhikrId'] ?? '') as String,
      targetCount: (map['targetCount'] as int?) ?? 0,
      currentCount: (map['currentCount'] as int?) ?? 0,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      duration: Duration(milliseconds: (map['duration'] as int?) ?? 0),
      date: DateTime.parse(map['date'] as String),
      clickTimes: (map['clickTimes'] as List<dynamic>?)
              ?.map((time) => DateTime.parse(time.toString()))
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from((map['metadata'] as Map?) ?? {}),
    );
  }

  @override
  String toString() {
    return 'DhikrSessionModel(id: $id, dhikrId: $dhikrId, currentCount: $currentCount/$targetCount, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DhikrSessionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}