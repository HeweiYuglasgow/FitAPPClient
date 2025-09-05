import 'package:json_annotation/json_annotation.dart';

part 'chart_data.g.dart';

/// Workout intensity data point
@JsonSerializable()
class WorkoutIntensityData {
  final String date;
  @JsonKey(name: 'day_index')
  final int dayIndex;
  @JsonKey(name: 'intensity_score')
  final double? intensityScore;
  @JsonKey(name: 'workout_count')
  final int workoutCount;
  @JsonKey(name: 'total_duration')
  final int totalDuration;

  const WorkoutIntensityData({
    required this.date,
    required this.dayIndex,
    this.intensityScore,
    required this.workoutCount,
    required this.totalDuration,
  });

  factory WorkoutIntensityData.fromJson(Map<String, dynamic> json) =>
      _$WorkoutIntensityDataFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutIntensityDataToJson(this);
}

/// Workout intensity trend response
@JsonSerializable()
class WorkoutIntensityTrend {
  final String period;
  @JsonKey(name: 'intensity_data')
  final List<WorkoutIntensityData> intensityData;

  const WorkoutIntensityTrend({
    required this.period,
    required this.intensityData,
  });

  factory WorkoutIntensityTrend.fromJson(Map<String, dynamic> json) =>
      _$WorkoutIntensityTrendFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutIntensityTrendToJson(this);
}

/// Mood correlation data point
@JsonSerializable()
class MoodCorrelationData {
  final String date;
  @JsonKey(name: 'day_index')
  final int dayIndex;
  @JsonKey(name: 'mood_before')
  final int? moodBefore;
  @JsonKey(name: 'mood_after')
  final int? moodAfter;
  @JsonKey(name: 'improvement_score')
  final double? improvementScore;
  @JsonKey(name: 'workout_completed')
  final bool workoutCompleted;

  const MoodCorrelationData({
    required this.date,
    required this.dayIndex,
    this.moodBefore,
    this.moodAfter,
    this.improvementScore,
    required this.workoutCompleted,
  });

  factory MoodCorrelationData.fromJson(Map<String, dynamic> json) =>
      _$MoodCorrelationDataFromJson(json);

  Map<String, dynamic> toJson() => _$MoodCorrelationDataToJson(this);
}

/// Mood correlation response
@JsonSerializable()
class MoodCorrelationTrend {
  final String period;
  @JsonKey(name: 'correlation_data')
  final List<MoodCorrelationData> correlationData;
  @JsonKey(name: 'average_improvement')
  final double averageImprovement;
  @JsonKey(name: 'correlation_strength')
  final double correlationStrength;

  const MoodCorrelationTrend({
    required this.period,
    required this.correlationData,
    required this.averageImprovement,
    required this.correlationStrength,
  });

  factory MoodCorrelationTrend.fromJson(Map<String, dynamic> json) =>
      _$MoodCorrelationTrendFromJson(json);

  Map<String, dynamic> toJson() => _$MoodCorrelationTrendToJson(this);
}