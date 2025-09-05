import 'package:flutter/foundation.dart';
import '../models/workout_plan.dart';
import '../models/workout_record.dart';
import '../models/workout_stats.dart';
import '../models/chart_data.dart';
import '../services/workout_service.dart';

/// Workout state management Provider
class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  
  WorkoutPlan? _currentPlan;
  WorkoutSession? _currentSession;
  List<WorkoutPlan> _recentPlans = [];
  List<WorkoutRecord> _recentRecords = [];
  WorkoutStats? _stats;
  WorkoutIntensityTrend? _intensityTrend;
  MoodCorrelationTrend? _moodCorrelationTrend;
  bool _isLoading = false;
  String? _errorMessage;
  
  /// Current workout plan
  WorkoutPlan? get currentPlan => _currentPlan;
  
  /// Current workout session
  WorkoutSession? get currentSession => _currentSession;
  
  /// Recent workout plans
  List<WorkoutPlan> get recentPlans => _recentPlans;
  
  /// Recent workout records
  List<WorkoutRecord> get recentRecords => _recentRecords;
  
  /// Workout statistics
  WorkoutStats? get stats => _stats;
  
  /// Workout intensity trend
  WorkoutIntensityTrend? get intensityTrend => _intensityTrend;
  
  /// Mood correlation trend
  MoodCorrelationTrend? get moodCorrelationTrend => _moodCorrelationTrend;
  
  /// Whether loading
  bool get isLoading => _isLoading;
  
  /// Error message
  String? get errorMessage => _errorMessage;
  
  /// Whether currently working out
  bool get isWorkingOut => _currentSession != null && !_currentSession!.isCompleted;
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Generate workout plan
  Future<WorkoutPlan?> generateWorkoutPlan({
    required String mood,
    required String scenario,
    String? intensity,
    List<String>? focusAreas,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _workoutService.generateWorkoutPlan(
        mood: mood,
        scenario: scenario,
        intensity: intensity,
        focusAreas: focusAreas,
      );
      
      if (response.success && response.data != null) {
        _currentPlan = response.data;
        notifyListeners();
        return _currentPlan;
      } else {
        _setError(response.message ?? 'Failed to generate workout plan');
        return null;
      }
    } catch (e) {
      _setError('Error occurred while generating workout plan');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Start workout
  void startWorkout(WorkoutPlan plan) {
    _currentPlan = plan;
    _currentSession = _workoutService.startWorkoutSession(plan);
    notifyListeners();
  }
  
  /// Mark exercise completed
  void markExerciseCompleted(int exerciseIndex) {
    if (_currentSession != null) {
      _currentSession!.markExerciseCompleted(exerciseIndex);
      notifyListeners();
    }
  }
  
  /// Unmark exercise completed
  void unmarkExerciseCompleted(int exerciseIndex) {
    if (_currentSession != null) {
      _currentSession!.unmarkExerciseCompleted(exerciseIndex);
      notifyListeners();
    }
  }
  
  /// Complete workout
  Future<bool> completeWorkout({
    String? notes,
    String? moodAfter,
  }) async {
    if (_currentSession == null || _currentPlan == null) return false;
    
    _setLoading(true);
    _setError(null);
    
    try {
      // Complete local session
      _currentSession!.completeWorkout(notes: notes, moodAfter: moodAfter);
      
      // Upload workout record
      final response = await _workoutService.recordWorkout(
        workoutPlanId: _currentPlan!.id!,
        completionRate: _currentSession!.completionRate,
        actualDuration: _currentSession!.actualDuration,
        completedExercises: _currentSession!.completedExercises,
        notes: notes,
        moodAfter: moodAfter,
      );
      
      if (response.success) {
        // Clear current session
        _currentSession = null;
        notifyListeners();
        
        // Refresh data
        loadRecentRecords();
        loadStats();
        
        return true;
      } else {
        _setError(response.message ?? 'Failed to save workout record');
        return false;
      }
    } catch (e) {
      _setError('Error occurred while completing workout');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Cancel workout
  void cancelWorkout() {
    _currentSession = null;
    notifyListeners();
  }
  
  /// Load recent workout plans
  Future<void> loadRecentPlans() async {
    try {
      final response = await _workoutService.getWorkoutPlans(limit: 10);
      if (response.success && response.data != null) {
        _recentPlans = response.data!.items;
        notifyListeners();
      }
    } catch (e) {
      // Handle errors silently
    }
  }
  
  /// Load recent workout records
  Future<void> loadRecentRecords() async {
    try {
      final response = await _workoutService.getWorkoutRecords(limit: 10);
      if (response.success && response.data != null) {
        _recentRecords = response.data!.items;
        notifyListeners();
      }
    } catch (e) {
      // Handle errors silently
    }
  }
  
  /// Load workout statistics
  Future<void> loadStats({String period = 'month'}) async {
    try {
      final response = await _workoutService.getWorkoutStats(period: period);
      if (response.success && response.data != null) {
        _stats = response.data;
        notifyListeners();
      }
    } catch (e) {
      // Handle errors silently
    }
  }

  /// Load workout intensity trend
  Future<void> loadIntensityTrend({int days = 7}) async {
    try {
      final response = await _workoutService.getWorkoutIntensityTrend(days: days);
      if (response.success && response.data != null) {
        _intensityTrend = response.data;
        notifyListeners();
      }
    } catch (e) {
      // Handle errors silently
    }
  }

  /// Load mood correlation trend
  Future<void> loadMoodCorrelationTrend({int days = 7}) async {
    try {
      final response = await _workoutService.getMoodCorrelationTrend(days: days);
      if (response.success && response.data != null) {
        _moodCorrelationTrend = response.data;
        notifyListeners();
      }
    } catch (e) {
      // Handle errors silently
    }
  }
  
  /// Get workout plan details
  Future<WorkoutPlan?> getWorkoutPlan(int id) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _workoutService.getWorkoutPlan(id);
      
      if (response.success && response.data != null) {
        return response.data;
      } else {
        _setError(response.message ?? 'Failed to get workout plan');
        return null;
      }
    } catch (e) {
      _setError('Error occurred while getting workout plan');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Initialize data
  Future<void> init() async {
    await Future.wait([
      loadRecentPlans(),
      loadRecentRecords(),
      loadStats(),
      loadIntensityTrend(),
      loadMoodCorrelationTrend(),
    ]);
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    await init();
  }
}