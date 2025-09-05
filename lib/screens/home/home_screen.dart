import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_button.dart';
import '../workout/workout_plan_screen.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';

/// Home Screen - Mood and context input
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scenarioController = TextEditingController();
  String? _selectedMood;
  
  // Mood options
  final List<Map<String, String>> _moodOptions = [
    {
      'value': AppConstants.moodGood,
      'label': 'Feeling Great',
      'emoji': '😊',
      'color': 'green',
    },
    {
      'value': AppConstants.moodNormal,
      'label': 'Okay',
      'emoji': '😐',
      'color': 'orange',
    },
    {
      'value': AppConstants.moodBad,
      'label': 'A Bit Down',
      'emoji': '😔',
      'color': 'red',
    },
  ];

  // Quick context tags
  final List<String> _quickScenarios = [
    'At home 30 min',
    'Gym 1 hour',
    'Outdoor running',
    'Office break',
    'Park walk',
    'Dorm workout',
  ];

  @override
  void dispose() {
    _scenarioController.dispose();
    super.dispose();
  }

  /// Get greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Get date display
  String _getDateDisplay() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[now.weekday - 1]}, ${now.month}/${now.day}';
  }

  /// Select quick context
  void _selectQuickScenario(String scenario) {
    setState(() {
      _scenarioController.text = scenario;
    });
  }

  /// Generate workout plan
  Future<void> _generateWorkoutPlan() async {
    if (_selectedMood == null) {
      _showSnackBar('Please select your mood first');
      return;
    }

    final scenarioValidation = Validators.validateScenario(_scenarioController.text);
    if (scenarioValidation != null) {
      _showSnackBar(scenarioValidation);
      return;
    }

    // Navigate to workout plan generation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutPlanScreen(
          mood: _selectedMood!,
          scenario: _scenarioController.text.trim(),
        ),
      ),
    );
  }

  /// Open AI assistant
  void _openAIAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  /// Open settings page
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  /// Show snack bar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Get mood color
  Color _getMoodColor(String mood) {
    return AppColors.getMoodColor(mood);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top greeting area
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()}, ${authProvider.user?.name ?? 'User'}',
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getDateDisplay(),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: AppColors.white,
                              ),
                              onPressed: _openSettings,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Mood selection area
              const Text(
                'How are you feeling today?',
                style: AppTextStyles.h5,
              ),
              const SizedBox(height: 16),
              Row(
                children: _moodOptions.map((mood) {
                  final isSelected = _selectedMood == mood['value'];
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = mood['value'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? _getMoodColor(mood['value']!).withOpacity(0.1) 
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? _getMoodColor(mood['value']!) 
                                  : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood['emoji']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood['label']!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected 
                                      ? _getMoodColor(mood['value']!) 
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Context input area
              const Text(
                'Tell me your workout context',
                style: AppTextStyles.h5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scenarioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g.: At home, 30 minutes, no equipment',
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick tags
              const Text(
                'Quick Select',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickScenarios.map((scenario) {
                  return GestureDetector(
                    onTap: () => _selectQuickScenario(scenario),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Text(
                        scenario,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons area
              LoadingButton(
                onPressed: _generateWorkoutPlan,
                text: 'Generate Workout Plan',
                icon: const Icon(Icons.fitness_center, color: AppColors.white),
              ),
              
              const SizedBox(height: 12),
              
              OutlineLoadingButton(
                onPressed: _openAIAssistant,
                text: 'Ask AI Coach',
                icon: Icon(Icons.chat_bubble_outline, color: AppColors.primary),
              ),
              
              const SizedBox(height: 32),
              
              // Daily tip card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Tip',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Exercise not only improves physical health but also effectively relieves stress and boosts mood. Even 5-10 minutes of light activity can make you feel positive changes!',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}