import 'package:json_annotation/json_annotation.dart';

part 'workout_record.g.dart';

/// 训练记录模型
@JsonSerializable()
class WorkoutRecord {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'workout_plan_id')
  final int workoutPlanId;
  @JsonKey(name: 'completion_rate')
  final double completionRate; // 完成率(0-100)
  @JsonKey(name: 'actual_duration')
  final int? actualDuration; // 实际训练时长(分钟)
  @JsonKey(name: 'completed_exercises')
  final List<int> completedExercises; // 已完成的动作ID列表
  final String? notes; // 训练备注
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  const WorkoutRecord({
    this.id,
    this.userId,
    required this.workoutPlanId,
    required this.completionRate,
    this.actualDuration,
    this.completedExercises = const [],
    this.notes,
    this.startedAt,
    this.completedAt,
  });

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => _$WorkoutRecordFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutRecordToJson(this);

  /// 创建训练记录副本
  WorkoutRecord copyWith({
    int? id,
    int? userId,
    int? workoutPlanId,
    double? completionRate,
    int? actualDuration,
    List<int>? completedExercises,
    String? notes,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return WorkoutRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      completionRate: completionRate ?? this.completionRate,
      actualDuration: actualDuration ?? this.actualDuration,
      completedExercises: completedExercises ?? this.completedExercises,
      notes: notes ?? this.notes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// 获取完成率百分比文本
  String get completionRateText {
    return '${completionRate.toStringAsFixed(0)}%';
  }

  /// Get actual workout duration text
  String get actualDurationText {
    if (actualDuration == null) return 'Not recorded';
    if (actualDuration! < 60) {
      return '${actualDuration} min';
    } else {
      final hours = actualDuration! ~/ 60;
      final minutes = actualDuration! % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  /// 是否完成训练
  bool get isCompleted => completedAt != null;

  /// Workout status text
  String get statusText {
    if (completedAt != null) {
      if (completionRate >= 100) {
        return 'Fully completed';
      } else if (completionRate >= 80) {
        return 'Mostly completed';
      } else if (completionRate >= 50) {
        return 'Partially completed';
      } else {
        return 'Low completion';
      }
    } else if (startedAt != null) {
      return 'In progress';
    } else {
      return 'Not started';
    }
  }

  /// 获取完成的动作数量
  int get completedExerciseCount => completedExercises.length;

  /// 训练持续时间(如果已开始)
  Duration? get trainingDuration {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  @override
  String toString() {
    return 'WorkoutRecord(id: $id, workoutPlanId: $workoutPlanId, completionRate: $completionRate, status: $statusText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutRecord &&
        other.id == id &&
        other.workoutPlanId == workoutPlanId &&
        other.completionRate == completionRate &&
        other.actualDuration == actualDuration;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        workoutPlanId.hashCode ^
        completionRate.hashCode ^
        actualDuration.hashCode;
  }
}