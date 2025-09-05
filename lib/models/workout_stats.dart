import 'package:json_annotation/json_annotation.dart';

part 'workout_stats.g.dart';

/// 训练统计数据模型
@JsonSerializable()
class WorkoutStats {
  @JsonKey(name: 'total_workouts')
  final int totalWorkouts; // 总训练次数
  @JsonKey(name: 'total_duration')
  final int totalDuration; // 总训练时长(分钟)
  @JsonKey(name: 'avg_completion_rate')
  final double avgCompletionRate; // 平均完成率
  @JsonKey(name: 'mood_improvement_rate')
  final double moodImprovementRate; // 情绪改善率
  @JsonKey(name: 'this_week')
  final WeeklyStats thisWeek; // 本周统计
  @JsonKey(name: 'mood_trends')
  final List<MoodTrend> moodTrends; // 情绪趋势

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.avgCompletionRate,
    required this.moodImprovementRate,
    required this.thisWeek,
    required this.moodTrends,
  });

  factory WorkoutStats.fromJson(Map<String, dynamic> json) => _$WorkoutStatsFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutStatsToJson(this);

  /// 获取总训练时长文本
  String get totalDurationText {
    if (totalDuration < 60) {
      return '${totalDuration}分钟';
    } else {
      final hours = totalDuration ~/ 60;
      final minutes = totalDuration % 60;
      return minutes > 0 ? '${hours}小时${minutes}分钟' : '${hours}小时';
    }
  }

  /// 获取平均完成率文本
  String get avgCompletionRateText {
    return '${avgCompletionRate.toStringAsFixed(1)}%';
  }

  /// 获取情绪改善率文本
  String get moodImprovementRateText {
    return '${moodImprovementRate.toStringAsFixed(1)}%';
  }
}

/// 本周统计数据
@JsonSerializable()
class WeeklyStats {
  final int workouts; // 本周训练次数
  final int duration; // 本周训练时长(分钟)

  const WeeklyStats({
    required this.workouts,
    required this.duration,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) => _$WeeklyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyStatsToJson(this);

  /// 获取本周训练时长文本
  String get durationText {
    if (duration < 60) {
      return '${duration}分钟';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return minutes > 0 ? '${hours}小时${minutes}分钟' : '${hours}小时';
    }
  }
}

/// 情绪趋势数据
@JsonSerializable()
class MoodTrend {
  final String date; // 日期
  final String before; // 运动前情绪
  final String after; // 运动后情绪

  const MoodTrend({
    required this.date,
    required this.before,
    required this.after,
  });

  factory MoodTrend.fromJson(Map<String, dynamic> json) => _$MoodTrendFromJson(json);

  Map<String, dynamic> toJson() => _$MoodTrendToJson(this);

  /// 获取运动前情绪评分
  int get beforeScore {
    switch (before) {
      case 'bad':
        return 1;
      case 'normal':
        return 2;
      case 'good':
        return 3;
      default:
        return 0;
    }
  }

  /// 获取运动后情绪评分
  int get afterScore {
    switch (after) {
      case 'bad':
        return 1;
      case 'normal':
        return 2;
      case 'good':
        return 3;
      default:
        return 0;
    }
  }

  /// 情绪是否改善
  bool get isImproved => afterScore > beforeScore;

  /// 情绪改善程度
  int get improvementLevel => afterScore - beforeScore;
}