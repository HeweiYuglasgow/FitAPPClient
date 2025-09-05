import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_button.dart';
import '../utils/validators.dart';
import 'main_navigation_screen.dart';

/// Personal information setup page
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedFitnessGoal;

  // Gender options
  final List<Map<String, String>> _genderOptions = [
    {
      'value': AppConstants.genderMale,
      'label': 'Male',
      'icon': 'male',
    },
    {
      'value': AppConstants.genderFemale,
      'label': 'Female',
      'icon': 'female',
    },
  ];

  // Fitness goal options
  final List<Map<String, String>> _fitnessGoalOptions = [
    {
      'value': AppConstants.goalMuscleGain,
      'label': 'Muscle Gain',
      'description': 'Increase muscle mass and strength',
      'icon': 'muscle',
    },
    {
      'value': AppConstants.goalWeightLoss,
      'label': 'Weight Loss',
      'description': 'Reduce body fat and improve physique',
      'icon': 'weight_loss',
    },
    {
      'value': AppConstants.goalMaintain,
      'label': 'Maintain',
      'description': 'Maintain current body condition',
      'icon': 'maintain',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// Load existing data
  void _loadExistingData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _nameController.text = user.name ?? '';
      _selectedGender = user.gender;
      _selectedFitnessGoal = user.fitnessGoal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Complete setup
  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      _showSnackBar('Please select gender');
      return;
    }

    if (_selectedFitnessGoal == null) {
      _showSnackBar('Please select fitness goal');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      gender: _selectedGender!,
      fitnessGoal: _selectedFitnessGoal!,
    );

    if (success) {
      // Setup complete, navigate to home page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    }
  }

  /// Show message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Get fitness goal icon
  IconData _getFitnessGoalIcon(String goal) {
    switch (goal) {
      case AppConstants.goalMuscleGain:
        return Icons.fitness_center;
      case AppConstants.goalWeightLoss:
        return Icons.speed;
      case AppConstants.goalMaintain:
        return Icons.balance;
      default:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome information
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to FitBuddy!',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please complete your profile to receive personalized fitness recommendations',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Name input
                const Text(
                  'Name',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateName,
                  decoration: const InputDecoration(
                    hintText: 'Please enter your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Gender selection
                const Text(
                  'Gender',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: _genderOptions.map((option) {
                    final isSelected = _selectedGender == option['value'];
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGender = option['value'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  option['value'] == AppConstants.genderMale
                                      ? Icons.man
                                      : Icons.woman,
                                  size: 32,
                                  color: isSelected ? AppColors.white : AppColors.grey600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  option['label']!,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Fitness goal selection
                const Text(
                  'Fitness Goal',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 12),
                ..._fitnessGoalOptions.map((option) {
                  final isSelected = _selectedFitnessGoal == option['value'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFitnessGoal = option['value'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.grey100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getFitnessGoalIcon(option['value']!),
                                color: isSelected ? AppColors.white : AppColors.grey600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['label']!,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['description']!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 32),
                
                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                // Complete button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return LoadingButton(
                      onPressed: _completeSetup,
                      isLoading: authProvider.isLoading,
                      text: 'Complete Setup',
                    );
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}