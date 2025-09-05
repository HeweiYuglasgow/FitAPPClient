import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout_plan.dart';
import '../../widgets/loading_button.dart';
import 'workout_session_screen.dart';

/// Workout plan display page
class WorkoutPlanScreen extends StatefulWidget {
  final String mood;
  final String scenario;

  const WorkoutPlanScreen({
    super.key,
    required this.mood,
    required this.scenario,
  });

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  WorkoutPlan? _workoutPlan;
  bool _isGenerating = true;
  final Set<int> _expandedExercises = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateWorkoutPlan();
    });
  }

  /// Generate workout plan
  Future<void> _generateWorkoutPlan() async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    
    final plan = await workoutProvider.generateWorkoutPlan(
      mood: widget.mood,
      scenario: widget.scenario,
    );

    setState(() {
      _workoutPlan = plan;
      _isGenerating = false;
    });
  }

  /// Start workout
  void _startWorkout() {
    if (_workoutPlan != null) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      workoutProvider.startWorkout(_workoutPlan!);
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WorkoutSessionScreen(plan: _workoutPlan!),
        ),
      );
    }
  }

  /// Save plan
  void _savePlan() {
    // TODO: Implement save to local favorites
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan saved to favorites')),
    );
  }

  /// Regenerate plan
  void _regeneratePlan() {
    setState(() {
      _isGenerating = true;
      _workoutPlan = null;
    });
    _generateWorkoutPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Today\'s Workout Plan'),
        actions: [
          if (_workoutPlan != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _regeneratePlan,
              tooltip: 'Regenerate',
            ),
        ],
      ),
      body: _isGenerating
          ? _buildLoadingView()
          : _workoutPlan != null
              ? _buildWorkoutPlanView()
              : _buildErrorView(),
    );
  }

  /// Build loading view
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'AI is generating your personalized workout plan...',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Please wait a moment',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Build workout plan view
  Widget _buildWorkoutPlanView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Plan overview card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _workoutPlan!.title,
                  style: AppTextStyles.h4.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 8),
                if (_workoutPlan!.description != null) ...[
                  Text(
                    _workoutPlan!.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.schedule,
                      label: '${_workoutPlan!.totalDuration} min',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.fitness_center,
                      label: '${_workoutPlan!.exerciseCount} exercises',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.mood,
                      label: _workoutPlan!.moodDisplayText,
                    ),
                  ],
                ),
                if (_workoutPlan!.motivationalMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _workoutPlan!.motivationalMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
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
          
          const SizedBox(height: 24),
          
          // Exercise list
          const Text(
            'Workout Content',
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: 16),
          
          ..._workoutPlan!.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: AppTextStyles.labelLarge,
                            ),
                            Text(
                              exercise.requirementText,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _expandedExercises.contains(index)
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_expandedExercises.contains(index)) {
                              _expandedExercises.remove(index);
                            } else {
                              _expandedExercises.add(index);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  // Expandable content - only show when expanded
                  if (_expandedExercises.contains(index)) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (exercise.description != null) ...[
                            Text(
                              'Description:',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise.description!,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (exercise.tips != null) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 16,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Tips:',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 22),
                              child: Text(
                                exercise.tips!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              if (exercise.targetMuscles != null) ...[
                                Chip(
                                  label: Text(
                                    exercise.targetMuscles!,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  side: BorderSide.none,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Chip(
                                label: Text(
                                  'Rest ${exercise.restTimeText}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                backgroundColor: AppColors.secondary.withOpacity(0.1),
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Collapsed state - show basic info
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (exercise.targetMuscles != null) ...[
                          Chip(
                            label: Text(
                              exercise.targetMuscles!,
                              style: AppTextStyles.bodySmall,
                            ),
                            backgroundColor: AppColors.grey100,
                            side: BorderSide.none,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Chip(
                          label: Text(
                            'Rest ${exercise.restTimeText}',
                            style: AppTextStyles.bodySmall,
                          ),
                          backgroundColor: AppColors.grey100,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 32),
          
          // Action buttons
          LoadingButton(
            onPressed: _startWorkout,
            text: 'Start Workout',
            icon: const Icon(Icons.play_arrow, color: AppColors.white),
          ),
          
          const SizedBox(height: 12),
          
          OutlineLoadingButton(
            onPressed: _savePlan,
            text: 'Save Plan',
            icon: Icon(Icons.bookmark_outline, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  workoutProvider.errorMessage ?? 'Failed to generate workout plan',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                LoadingButton(
                  onPressed: _regeneratePlan,
                  text: 'Regenerate',
                  icon: const Icon(Icons.refresh, color: AppColors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build info chip
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}