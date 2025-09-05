import 'package:json_annotation/json_annotation.dart';
import 'exercise.dart';

part 'workout_plan.g.dart';

/// Workout plan model
@JsonSerializable()
class WorkoutPlan {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  final String title;
  final String? description;
  @JsonKey(name: 'total_duration')
  final int totalDuration; // Total duration (minutes)
  final String? location;
  final String? equipment;
  @JsonKey(name: 'mood_context')
  final String moodContext; // good, normal, bad
  final List<Exercise> exercises;
  @JsonKey(name: 'motivational_message')
  final String? motivationalMessage;
  @JsonKey(name: 'generated_at')
  final DateTime? generatedAt;

  const WorkoutPlan({
    this.id,
    this.userId,
    required this.title,
    this.description,
    required this.totalDuration,
    this.location,
    this.equipment,
    required this.moodContext,
    required this.exercises,
    this.motivationalMessage,
    this.generatedAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutPlanToJson(this);

  /// Create workout plan copy
  WorkoutPlan copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    int? totalDuration,
    String? location,
    String? equipment,
    String? moodContext,
    List<Exercise>? exercises,
    String? motivationalMessage,
    DateTime? generatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      totalDuration: totalDuration ?? this.totalDuration,
      location: location ?? this.location,
      equipment: equipment ?? this.equipment,
      moodContext: moodContext ?? this.moodContext,
      exercises: exercises ?? this.exercises,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// Get mood state display text
  String get moodDisplayText {
    switch (moodContext) {
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

  /// Get total number of exercises
  int get exerciseCount => exercises.length;

  /// Get completion status (needs to be queried from database)
  bool get isCompleted => false; // This needs to be retrieved from records

  @override
  String toString() {
    return 'WorkoutPlan(id: $id, title: $title, totalDuration: $totalDuration, exerciseCount: $exerciseCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutPlan &&
        other.id == id &&
        other.title == title &&
        other.totalDuration == totalDuration &&
        other.moodContext == moodContext;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        totalDuration.hashCode ^
        moodContext.hashCode;
  }
}