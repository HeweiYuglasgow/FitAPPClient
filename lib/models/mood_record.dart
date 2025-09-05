import 'package:json_annotation/json_annotation.dart';

part 'mood_record.g.dart';

/// Mood record model
@JsonSerializable()
class MoodRecord {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'mood_before')
  final String moodBefore; // good, normal, bad
  @JsonKey(name: 'mood_after')
  final String? moodAfter; // good, normal, bad
  @JsonKey(name: 'workout_id')
  final int? workoutId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const MoodRecord({
    this.id,
    this.userId,
    required this.moodBefore,
    this.moodAfter,
    this.workoutId,
    this.createdAt,
  });

  factory MoodRecord.fromJson(Map<String, dynamic> json) => _$MoodRecordFromJson(json);

  Map<String, dynamic> toJson() => _$MoodRecordToJson(this);

  /// Create mood record copy
  MoodRecord copyWith({
    int? id,
    int? userId,
    String? moodBefore,
    String? moodAfter,
    int? workoutId,
    DateTime? createdAt,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      workoutId: workoutId ?? this.workoutId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get pre-workout mood display text
  String get moodBeforeDisplayText {
    return _getMoodDisplayText(moodBefore);
  }

  /// Get post-workout mood display text
  String get moodAfterDisplayText {
    if (moodAfter == null) return 'Not recorded';
    return _getMoodDisplayText(moodAfter!);
  }

  /// Get mood display text
  String _getMoodDisplayText(String mood) {
    switch (mood) {
      case 'good':
        return 'Good mood';
      case 'normal':
        return 'Okay';
      case 'bad':
        return 'A bit down';
      default:
        return 'Unknown';
    }
  }

  /// Get pre-workout mood emoji
  String get moodBeforeEmoji {
    return _getMoodEmoji(moodBefore);
  }

  /// Get post-workout mood emoji
  String get moodAfterEmoji {
    if (moodAfter == null) return '❓';
    return _getMoodEmoji(moodAfter!);
  }

  /// Get mood emoji
  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'good':
        return '😊';
      case 'normal':
        return '😐';
      case 'bad':
        return '😔';
      default:
        return '❓';
    }
  }

  /// Whether mood has improved
  bool get isMoodImproved {
    if (moodAfter == null) return false;
    return _getMoodScore(moodAfter!) > _getMoodScore(moodBefore);
  }

  /// Get mood score
  int _getMoodScore(String mood) {
    switch (mood) {
      case 'bad':
        return 1;
      case 'normal':
        return 2;
      case 'good':
        return 3;
      default:
        return 0;
    }
  }

  /// Mood improvement level
  int get moodImprovementLevel {
    if (moodAfter == null) return 0;
    return _getMoodScore(moodAfter!) - _getMoodScore(moodBefore);
  }

  @override
  String toString() {
    return 'MoodRecord(id: $id, moodBefore: $moodBefore, moodAfter: $moodAfter, workoutId: $workoutId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodRecord &&
        other.id == id &&
        other.moodBefore == moodBefore &&
        other.moodAfter == moodAfter &&
        other.workoutId == workoutId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        moodBefore.hashCode ^
        moodAfter.hashCode ^
        workoutId.hashCode;
  }
}