// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutIntensityData _$WorkoutIntensityDataFromJson(
  Map<String, dynamic> json,
) => WorkoutIntensityData(
  date: json['date'] as String,
  dayIndex: (json['day_index'] as num).toInt(),
  intensityScore: (json['intensity_score'] as num?)?.toDouble(),
  workoutCount: (json['workout_count'] as num).toInt(),
  totalDuration: (json['total_duration'] as num).toInt(),
);

Map<String, dynamic> _$WorkoutIntensityDataToJson(
  WorkoutIntensityData instance,
) => <String, dynamic>{
  'date': instance.date,
  'day_index': instance.dayIndex,
  'intensity_score': instance.intensityScore,
  'workout_count': instance.workoutCount,
  'total_duration': instance.totalDuration,
};

WorkoutIntensityTrend _$WorkoutIntensityTrendFromJson(
  Map<String, dynamic> json,
) => WorkoutIntensityTrend(
  period: json['period'] as String,
  intensityData: (json['intensity_data'] as List<dynamic>)
      .map((e) => WorkoutIntensityData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WorkoutIntensityTrendToJson(
  WorkoutIntensityTrend instance,
) => <String, dynamic>{
  'period': instance.period,
  'intensity_data': instance.intensityData,
};

MoodCorrelationData _$MoodCorrelationDataFromJson(Map<String, dynamic> json) =>
    MoodCorrelationData(
      date: json['date'] as String,
      dayIndex: (json['day_index'] as num).toInt(),
      moodBefore: (json['mood_before'] as num?)?.toInt(),
      moodAfter: (json['mood_after'] as num?)?.toInt(),
      improvementScore: (json['improvement_score'] as num?)?.toDouble(),
      workoutCompleted: json['workout_completed'] as bool,
    );

Map<String, dynamic> _$MoodCorrelationDataToJson(
  MoodCorrelationData instance,
) => <String, dynamic>{
  'date': instance.date,
  'day_index': instance.dayIndex,
  'mood_before': instance.moodBefore,
  'mood_after': instance.moodAfter,
  'improvement_score': instance.improvementScore,
  'workout_completed': instance.workoutCompleted,
};

MoodCorrelationTrend _$MoodCorrelationTrendFromJson(
  Map<String, dynamic> json,
) => MoodCorrelationTrend(
  period: json['period'] as String,
  correlationData: (json['correlation_data'] as List<dynamic>)
      .map((e) => MoodCorrelationData.fromJson(e as Map<String, dynamic>))
      .toList(),
  averageImprovement: (json['average_improvement'] as num).toDouble(),
  correlationStrength: (json['correlation_strength'] as num).toDouble(),
);

Map<String, dynamic> _$MoodCorrelationTrendToJson(
  MoodCorrelationTrend instance,
) => <String, dynamic>{
  'period': instance.period,
  'correlation_data': instance.correlationData,
  'average_improvement': instance.averageImprovement,
  'correlation_strength': instance.correlationStrength,
};
