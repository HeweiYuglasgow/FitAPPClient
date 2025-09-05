// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodRecord _$MoodRecordFromJson(Map<String, dynamic> json) => MoodRecord(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  moodBefore: json['mood_before'] as String,
  moodAfter: json['mood_after'] as String?,
  workoutId: (json['workout_id'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MoodRecordToJson(MoodRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'mood_before': instance.moodBefore,
      'mood_after': instance.moodAfter,
      'workout_id': instance.workoutId,
      'created_at': instance.createdAt?.toIso8601String(),
    };
