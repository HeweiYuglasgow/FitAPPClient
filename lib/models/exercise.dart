import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

/// 运动动作模型
@JsonSerializable()
class Exercise {
  final int? id;
  final String name;
  final String? description;
  final int sets; // 组数
  final int? reps; // 次数
  final int? duration; // 持续时间(秒)
  @JsonKey(name: 'rest_time')
  final int restTime; // 组间休息时间(秒)
  @JsonKey(name: 'target_muscles')
  final String? targetMuscles; // 目标肌群
  final String? tips; // 动作要点
  final int order; // 动作顺序

  const Exercise({
    this.id,
    required this.name,
    this.description,
    required this.sets,
    this.reps,
    this.duration,
    required this.restTime,
    this.targetMuscles,
    this.tips,
    this.order = 0, // 默认值为0，因为API响应中可能没有此字段
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // 处理API响应中可能缺少order字段的情况
    final exerciseJson = Map<String, dynamic>.from(json);
    if (!exerciseJson.containsKey('order')) {
      exerciseJson['order'] = 0; // 设置默认值
    }
    return _$ExerciseFromJson(exerciseJson);
  }

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  /// 创建动作副本
  Exercise copyWith({
    int? id,
    String? name,
    String? description,
    int? sets,
    int? reps,
    int? duration,
    int? restTime,
    String? targetMuscles,
    String? tips,
    int? order,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      restTime: restTime ?? this.restTime,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      tips: tips ?? this.tips,
      order: order ?? this.order,
    );
  }

  /// Get training requirement text
  String get requirementText {
    if (reps != null) {
      return '$sets sets x $reps reps';
    } else if (duration != null) {
      return '$sets sets x ${duration}s';
    } else {
      return '$sets sets';
    }
  }

  /// Get rest time text
  String get restTimeText {
    if (restTime < 60) {
      return '${restTime}s';
    } else {
      final minutes = restTime ~/ 60;
      final seconds = restTime % 60;
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes} min';
    }
  }

  /// 是否是计时动作
  bool get isTimeBased => duration != null && duration! > 0;

  /// 是否是计次动作
  bool get isRepBased => reps != null && reps! > 0;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, sets: $sets, reps: $reps, duration: $duration, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise &&
        other.id == id &&
        other.name == name &&
        other.sets == sets &&
        other.reps == reps &&
        other.duration == duration &&
        other.order == order;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        sets.hashCode ^
        reps.hashCode ^
        duration.hashCode ^
        order.hashCode;
  }
}