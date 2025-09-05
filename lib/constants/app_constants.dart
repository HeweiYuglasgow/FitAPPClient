/// Application constants
class AppConstants {
  /// Application name
  static const String appName = 'FitBuddy';
  
  /// API base URL
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String devApiBaseUrl = 'http://127.0.0.1:8000/api/v1';
  
  /// Local storage key names
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String languageKey = 'language';
  
  /// Network timeout (milliseconds)
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
  static const int sendTimeout = 10000;
  
  /// Pagination parameters
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  /// Animation duration
  static const int defaultAnimationDuration = 300;
  static const int splashScreenDuration = 2000;
  
  /// Workout related constants
  static const int minWorkoutDuration = 5; // Minimum workout duration (minutes)
  static const int maxWorkoutDuration = 120; // Maximum workout duration (minutes)
  static const int defaultRestTime = 30; // Default rest time (seconds)
  
  /// Mood states
  static const String moodGood = 'good';
  static const String moodNormal = 'normal';
  static const String moodBad = 'bad';
  
  /// Gender options
  static const String genderMale = 'male';
  static const String genderFemale = 'female';
  
  /// Fitness goals
  static const String goalMuscleGain = 'muscle_gain';
  static const String goalWeightLoss = 'weight_loss';
  static const String goalMaintain = 'maintain';
  
  /// Error messages
  static const String networkErrorMessage = 'Network connection error, please check network settings';
  static const String serverErrorMessage = 'Server error, please try again later';
  static const String unknownErrorMessage = 'Unknown error, please try again later';
  static const String authErrorMessage = 'Login has expired, please log in again';
  static const String validationErrorMessage = 'Input information is incorrect, please check and try again';
  
  /// Success messages
  static const String loginSuccessMessage = 'Login successful';
  static const String registerSuccessMessage = 'Registration successful';
  static const String logoutSuccessMessage = 'Logout successful';
  static const String saveSuccessMessage = 'Save successful';
  static const String deleteSuccessMessage = 'Delete successful';
  static const String workoutCompleteMessage = 'Workout completed, great job!';
  
  /// Regular expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordRegex = r'^.{6,}$'; // At least 6 characters
  
  /// File related
  static const String databaseName = 'fitbuddy.db';
  static const int databaseVersion = 1;
  
  /// Image related
  static const double defaultAvatarSize = 80.0;
  static const double defaultIconSize = 24.0;
  
  /// Page route names
  static const String splashRoute = '/splash';
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String profileSetupRoute = '/profile-setup';
  static const String workoutPlanRoute = '/workout-plan';
  static const String workoutSessionRoute = '/workout-session';
  static const String statsRoute = '/stats';
  static const String chatRoute = '/chat';
  static const String settingsRoute = '/settings';
}