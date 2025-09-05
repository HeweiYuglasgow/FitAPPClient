import '../models/workout_plan.dart';
import '../models/workout_record.dart';
import '../models/workout_stats.dart';
import '../models/chart_data.dart';
import '../models/api_response.dart';
import 'http_service.dart';

/// Workout service class
class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  final HttpService _httpService = HttpService();

  /// Generate workout plan
  Future<ApiResponse<WorkoutPlan>> generateWorkoutPlan({
    required String mood,
    required String scenario,
    String? intensity,
    List<String>? focusAreas,
  }) async {
    final Map<String, dynamic> data = {
      'mood': mood,
      'scenario': scenario,
    };

    if (intensity != null || focusAreas != null) {
      data['preferences'] = {
        'mood': mood, // 在偏好设置中也包含心情状态
      };
      if (intensity != null) data['preferences']['intensity'] = intensity;
      if (focusAreas != null) data['preferences']['focus_areas'] = focusAreas;
    } else {
      // 即使没有其他偏好设置，也要包含心情状态
      data['preferences'] = {
        'mood': mood,
      };
    }

    final response = await _httpService.post(
      '/workout/generate',
      data: data,
      fromJson: (data) => WorkoutPlan.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// Get workout plans list
  Future<ApiResponse<PaginatedResponse<WorkoutPlan>>> getWorkoutPlans({
    int page = 1,
    int limit = 10,
    String? dateFrom,
    String? dateTo,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
    };

    if (dateFrom != null) queryParameters['date_from'] = dateFrom;
    if (dateTo != null) queryParameters['date_to'] = dateTo;

    final response = await _httpService.get(
      '/workout/plans',
      queryParameters: queryParameters,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return PaginatedResponse<WorkoutPlan>(
            items: (data['plans'] as List<dynamic>)
                .map((item) => WorkoutPlan.fromJson(item as Map<String, dynamic>))
                .toList(),
            pagination: Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
          );
        }
        throw Exception('Invalid response format');
      },
    );

    return response;
  }

  /// Get workout plan details
  Future<ApiResponse<WorkoutPlan>> getWorkoutPlan(int id) async {
    final response = await _httpService.get(
      '/workout/plans/$id',
      fromJson: (data) => WorkoutPlan.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// Record workout completion
  Future<ApiResponse<WorkoutRecord>> recordWorkout({
    required int workoutPlanId,
    required double completionRate,
    int? actualDuration,
    List<int>? completedExercises,
    String? notes,
    String? moodAfter,
  }) async {
    final Map<String, dynamic> data = {
      'workout_plan_id': workoutPlanId,
      'completion_rate': completionRate,
    };

    if (actualDuration != null) data['actual_duration'] = actualDuration;
    if (completedExercises != null) data['completed_exercises'] = completedExercises;
    if (notes != null) data['notes'] = notes;
    if (moodAfter != null) data['mood_after'] = moodAfter;

    final response = await _httpService.post(
      '/workout/records',
      data: data,
      fromJson: (data) => WorkoutRecord.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// Get workout records list
  Future<ApiResponse<PaginatedResponse<WorkoutRecord>>> getWorkoutRecords({
    int page = 1,
    int limit = 10,
    String? dateFrom,
    String? dateTo,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
    };

    if (dateFrom != null) queryParameters['date_from'] = dateFrom;
    if (dateTo != null) queryParameters['date_to'] = dateTo;

    final response = await _httpService.get(
      '/workout/records',
      queryParameters: queryParameters,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return PaginatedResponse<WorkoutRecord>(
            items: (data['records'] as List<dynamic>)
                .map((item) => WorkoutRecord.fromJson(item as Map<String, dynamic>))
                .toList(),
            pagination: Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
          );
        }
        throw Exception('Invalid response format');
      },
    );

    return response;
  }

  /// 获取训练统计数据
  Future<ApiResponse<WorkoutStats>> getWorkoutStats({
    String period = 'month',
  }) async {
    final response = await _httpService.get(
      '/workout/stats',
      queryParameters: {'period': period},
      fromJson: (data) => WorkoutStats.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// Get workout intensity trend data
  Future<ApiResponse<WorkoutIntensityTrend>> getWorkoutIntensityTrend({
    int days = 7,
  }) async {
    final response = await _httpService.get(
      '/stats/workout-intensity',
      queryParameters: {'days': days},
      fromJson: (data) => WorkoutIntensityTrend.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// Get mood correlation trend data
  Future<ApiResponse<MoodCorrelationTrend>> getMoodCorrelationTrend({
    int days = 7,
  }) async {
    final response = await _httpService.get(
      '/stats/mood-correlation',
      queryParameters: {'days': days},
      fromJson: (data) => MoodCorrelationTrend.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// 开始训练记录
  WorkoutSession startWorkoutSession(WorkoutPlan plan) {
    return WorkoutSession(plan: plan);
  }
}

/// 训练会话类，用于跟踪训练进度
class WorkoutSession {
  final WorkoutPlan plan;
  final DateTime startTime;
  final List<int> completedExercises = [];
  DateTime? endTime;
  String? notes;
  String? moodAfter;

  WorkoutSession({
    required this.plan,
  }) : startTime = DateTime.now();

  /// 标记动作完成
  void markExerciseCompleted(int exerciseIndex) {
    if (!completedExercises.contains(exerciseIndex)) {
      completedExercises.add(exerciseIndex);
    }
  }

  /// 取消动作完成
  void unmarkExerciseCompleted(int exerciseIndex) {
    completedExercises.remove(exerciseIndex);
  }

  /// 检查动作是否完成
  bool isExerciseCompleted(int exerciseIndex) {
    return completedExercises.contains(exerciseIndex);
  }

  /// 完成训练
  void completeWorkout({String? notes, String? moodAfter}) {
    endTime = DateTime.now();
    this.notes = notes;
    this.moodAfter = moodAfter;
  }

  /// 获取完成率
  double get completionRate {
    if (plan.exercises.isEmpty) return 0.0;
    return (completedExercises.length / plan.exercises.length) * 100;
  }

  /// 获取实际训练时长（分钟）
  int? get actualDuration {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  /// 获取当前训练时长（分钟）
  int get currentDuration {
    final now = endTime ?? DateTime.now();
    return now.difference(startTime).inMinutes;
  }

  /// 是否已完成
  bool get isCompleted => endTime != null;
}