import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'services/http_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_navigation_screen.dart';

/// FitBuddy fitness app main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HTTP service
  await HttpService().init();
  
  runApp(const FitBuddyApp());
}

/// FitBuddy app main component
class FitBuddyApp extends StatelessWidget {
  const FitBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/profile-setup': (context) => const ProfileSetupScreen(),
          '/home': (context) => const MainNavigationScreen(),
        },
      ),
    );
  }
}
