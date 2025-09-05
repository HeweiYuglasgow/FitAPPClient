import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/workout_plan.dart';
import '../../models/exercise.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/loading_button.dart';

/// Workout execution page
class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutPlan plan;

  const WorkoutSessionScreen({
    super.key,
    required this.plan,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _restProgressController;
  int _currentExerciseIndex = 0;
  bool _isResting = false;
  int _restTimeRemaining = 0;
  int _totalRestTime = 0;
  String? _selectedMoodAfter;
  final _notesController = TextEditingController();

  // Post-workout mood options
  final List<Map<String, String>> _moodOptions = [
    {'value': 'good', 'label': 'Great', 'emoji': '😊'},
    {'value': 'normal', 'label': 'Good', 'emoji': '😐'},
    {'value': 'bad', 'label': 'Tired', 'emoji': '😔'},
  ];

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _restProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    _restProgressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Get current exercise
  Exercise get currentExercise => widget.plan.exercises[_currentExerciseIndex];

  /// Toggle exercise completion status
  void _toggleExerciseCompletion(int exerciseIndex) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    
    if (workoutProvider.currentSession?.isExerciseCompleted(exerciseIndex) ?? false) {
      workoutProvider.unmarkExerciseCompleted(exerciseIndex);
    } else {
      workoutProvider.markExerciseCompleted(exerciseIndex);
    }
  }

  /// Start rest countdown
  void _startRest() {
    setState(() {
      _isResting = true;
      _restTimeRemaining = currentExercise.restTime;
      _totalRestTime = currentExercise.restTime;
    });

    // Set initial progress value
    _restProgressController.value = 1.0;
    _timerController.repeat();
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isResting) {
        timer.cancel();
        _timerController.stop();
        _restProgressController.stop();
        return;
      }

      setState(() {
        _restTimeRemaining--;
        
        // Update progress animation
        if (_totalRestTime > 0) {
          _restProgressController.value = _restTimeRemaining / _totalRestTime;
        }
      });

      if (_restTimeRemaining <= 0) {
        timer.cancel();
        _timerController.stop();
        _restProgressController.stop();
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  /// Skip rest
  void _skipRest() {
    setState(() {
      _isResting = false;
      _restTimeRemaining = 0;
    });
    _timerController.stop();
    _restProgressController.stop();
  }

  /// Next exercise
  void _nextExercise() {
    if (_currentExerciseIndex < widget.plan.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    } else {
      _showCompleteDialog();
    }
  }

  /// Previous exercise
  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
    }
  }

  /// Show completion dialog
  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Workout Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Congratulations! You completed today\'s workout!'),
              const SizedBox(height: 16),
              const Text('Please share how you feel after the workout:'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _moodOptions.map((mood) {
                  final isSelected = _selectedMoodAfter == mood['value'];
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        _selectedMoodAfter = mood['value'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected 
                            ? Border.all(color: AppColors.primary) 
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(mood['emoji']!, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(mood['label']!, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Workout Notes (Optional)',
                  hintText: 'Record your workout experience today...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeWorkout();
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }

  /// Complete workout
  Future<void> _completeWorkout() async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    
    final success = await workoutProvider.completeWorkout(
      notes: _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() 
          : null,
      moodAfter: _selectedMoodAfter,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout record saved, keep it up!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Pause/Resume workout
  void _pauseWorkout() {
    // TODO: Implement workout pause functionality
  }

  /// Exit workout
  void _exitWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout'),
        content: const Text('Are you sure you want to exit the current workout? Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
              workoutProvider.cancelWorkout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Workout in Progress (${_currentExerciseIndex + 1}/${widget.plan.exercises.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: _pauseWorkout,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitWorkout,
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          return Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (_currentExerciseIndex + 1) / widget.plan.exercises.length,
                backgroundColor: AppColors.grey200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              
              Expanded(
                child: _isResting ? _buildRestView() : _buildExerciseView(workoutProvider),
              ),
              
              // Bottom control bar
              _buildBottomControls(workoutProvider),
            ],
          );
        },
      ),
    );
  }

  /// Build exercise view
  Widget _buildExerciseView(WorkoutProvider workoutProvider) {
    final exercise = currentExercise;
    final isCompleted = workoutProvider.currentSession?.isExerciseCompleted(_currentExerciseIndex) ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Exercise information card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Exercise icon/animation area
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Exercise name
                Text(
                  exercise.name,
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Training requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exercise.requirementText,
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                if (exercise.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    exercise.description!,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
                
                if (exercise.tips != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise.tips!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Complete button
          LoadingButton(
            onPressed: () => _toggleExerciseCompletion(_currentExerciseIndex),
            text: isCompleted ? 'Completed' : 'Mark Complete',
            backgroundColor: isCompleted ? AppColors.success : AppColors.primary,
            icon: Icon(
              isCompleted ? Icons.check_circle : Icons.check,
              color: AppColors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Start rest button
          if (exercise.restTime > 0)
            OutlineLoadingButton(
              onPressed: _startRest,
              text: 'Start Rest (${exercise.restTimeText})',
              icon: Icon(Icons.timer, color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  /// Build rest view
  Widget _buildRestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rest countdown with progress circle
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress circle
              SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _restProgressController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _restProgressController.value,
                      strokeWidth: 8,
                      backgroundColor: AppColors.grey200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _restTimeRemaining <= 5 
                            ? AppColors.warning 
                            : AppColors.secondary,
                      ),
                    );
                  },
                ),
              ),
              // Time display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_restTimeRemaining',
                    style: AppTextStyles.numberLarge.copyWith(
                      fontSize: 48,
                      color: _restTimeRemaining <= 5 
                          ? AppColors.warning 
                          : AppColors.secondary,
                    ),
                  ),
                  Text(
                    'sec',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _restTimeRemaining <= 5 
                          ? AppColors.warning 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Rest Time',
            style: AppTextStyles.h4,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Relax and prepare for the next exercise',
            style: AppTextStyles.bodyMedium,
          ),
          
          const SizedBox(height: 48),
          
          // Skip rest button
          OutlineLoadingButton(
            onPressed: _skipRest,
            text: 'Skip Rest',
          ),
        ],
      ),
    );
  }

  /// Build bottom control bar
  Widget _buildBottomControls(WorkoutProvider workoutProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: OutlineLoadingButton(
              onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
              text: 'Previous',
              width: double.infinity,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Completion rate display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${workoutProvider.currentSession?.completionRate.toStringAsFixed(0) ?? 0}%',
                  style: AppTextStyles.numberSmall,
                ),
                const Text(
                  'Complete',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Next button
          Expanded(
            child: LoadingButton(
              onPressed: _nextExercise,
              text: _currentExerciseIndex < widget.plan.exercises.length - 1 
                  ? 'Next' 
                  : 'Complete',
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}