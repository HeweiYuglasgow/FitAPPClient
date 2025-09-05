// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutRecord _$WorkoutRecordFromJson(Map<String, dynamic> json) =>
    WorkoutRecord(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      workoutPlanId: (json['workout_plan_id'] as num).toInt(),
      completionRate: (json['completion_rate'] as num).toDouble(),
      actualDuration: (json['actual_duration'] as num?)?.toInt(),
      completedExercises:
          (json['completed_exercises'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$WorkoutRecordToJson(WorkoutRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'workout_plan_id': instance.workoutPlanId,
      'completion_rate': instance.completionRate,
      'actual_duration': instance.actualDuration,
      'completed_exercises': instance.completedExercises,
      'notes': instance.notes,
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };
