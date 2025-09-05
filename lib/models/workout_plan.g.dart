// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) => WorkoutPlan(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  totalDuration: (json['total_duration'] as num).toInt(),
  location: json['location'] as String?,
  equipment: json['equipment'] as String?,
  moodContext: json['mood_context'] as String,
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
      .toList(),
  motivationalMessage: json['motivational_message'] as String?,
  generatedAt: json['generated_at'] == null
      ? null
      : DateTime.parse(json['generated_at'] as String),
);

Map<String, dynamic> _$WorkoutPlanToJson(WorkoutPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'total_duration': instance.totalDuration,
      'location': instance.location,
      'equipment': instance.equipment,
      'mood_context': instance.moodContext,
      'exercises': instance.exercises,
      'motivational_message': instance.motivationalMessage,
      'generated_at': instance.generatedAt?.toIso8601String(),
    };
