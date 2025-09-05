// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutStats _$WorkoutStatsFromJson(Map<String, dynamic> json) => WorkoutStats(
  totalWorkouts: (json['total_workouts'] as num).toInt(),
  totalDuration: (json['total_duration'] as num).toInt(),
  avgCompletionRate: (json['avg_completion_rate'] as num).toDouble(),
  moodImprovementRate: (json['mood_improvement_rate'] as num).toDouble(),
  thisWeek: WeeklyStats.fromJson(json['this_week'] as Map<String, dynamic>),
  moodTrends: (json['mood_trends'] as List<dynamic>)
      .map((e) => MoodTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WorkoutStatsToJson(WorkoutStats instance) =>
    <String, dynamic>{
      'total_workouts': instance.totalWorkouts,
      'total_duration': instance.totalDuration,
      'avg_completion_rate': instance.avgCompletionRate,
      'mood_improvement_rate': instance.moodImprovementRate,
      'this_week': instance.thisWeek,
      'mood_trends': instance.moodTrends,
    };

WeeklyStats _$WeeklyStatsFromJson(Map<String, dynamic> json) => WeeklyStats(
  workouts: (json['workouts'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
);

Map<String, dynamic> _$WeeklyStatsToJson(WeeklyStats instance) =>
    <String, dynamic>{
      'workouts': instance.workouts,
      'duration': instance.duration,
    };

MoodTrend _$MoodTrendFromJson(Map<String, dynamic> json) => MoodTrend(
  date: json['date'] as String,
  before: json['before'] as String,
  after: json['after'] as String,
);

Map<String, dynamic> _$MoodTrendToJson(MoodTrend instance) => <String, dynamic>{
  'date': instance.date,
  'before': instance.before,
  'after': instance.after,
};
