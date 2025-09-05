// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  sets: (json['sets'] as num).toInt(),
  reps: (json['reps'] as num?)?.toInt(),
  duration: (json['duration'] as num?)?.toInt(),
  restTime: (json['rest_time'] as num).toInt(),
  targetMuscles: json['target_muscles'] as String?,
  tips: json['tips'] as String?,
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'sets': instance.sets,
  'reps': instance.reps,
  'duration': instance.duration,
  'rest_time': instance.restTime,
  'target_muscles': instance.targetMuscles,
  'tips': instance.tips,
  'order': instance.order,
};
