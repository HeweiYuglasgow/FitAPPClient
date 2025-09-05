import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'http_service.dart';

/// Authentication Service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpService _httpService = HttpService();
  User? _currentUser;

  /// Get current user
  User? get currentUser => _currentUser;

  /// Is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Initialize authentication service
  Future<void> init() async {
    await _loadUserFromStorage();
  }

  /// Load user info from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      }
    } catch (e) {
      print('Failed to load user info: $e');
      // Clear potentially corrupted data
      await _clearUserFromStorage();
    }
  }

  /// Save user info to local storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(AppConstants.userKey, userJson);
    } catch (e) {
      print('Failed to save user info: $e');
    }
  }

  /// Clear user info from local storage
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userKey);
    } catch (e) {
      print('Failed to clear user info: $e');
    }
  }

  /// Send verification code
  Future<ApiResponse<void>> sendVerificationCode({
    required String email,
    String type = 'register',
  }) async {
    final response = await _httpService.post(
      '/auth/send-code',
      data: {
        'email': email,
        'type': type,
      },
    );
    
    return ApiResponse<void>(
      success: response.success,
      message: response.message,
    );
  }

  /// User registration
  Future<ApiResponse<User?>> register({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    // Use auth-specific method to get complete response
    final authData = await _httpService.postForAuth('/auth/register', data: {
      'email': email,
      'password': password,
      'verification_code': verificationCode,
    });

    if (authData != null) {
      // Extract and set token (based on backend response structure: data.token)
      if (authData['data'] != null && authData['data']['token'] != null) {
        await _httpService.setAuthToken(authData['data']['token'] as String);
      }

      // Extract user data (based on backend response structure: data.user)
      User? user;
      if (authData['data'] != null && authData['data']['user'] != null) {
        user = User.fromJson(authData['data']['user'] as Map<String, dynamic>);
      }

      if (user != null) {
        _currentUser = user;
        await _saveUserToStorage(_currentUser!);
        return ApiResponse<User?>.success(data: user, message: authData['message'] as String?);
      }
    }

    return ApiResponse<User?>.error(message: 'Registration failed');
  }

  /// User login
  Future<ApiResponse<User?>> login({
    required String email,
    required String password,
  }) async {
    // Use auth-specific method to get complete response
    final authData = await _httpService.postForAuth('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (authData != null) {
      // Extract and set token (based on backend response structure: data.token)
      if (authData['data'] != null && authData['data']['token'] != null) {
        await _httpService.setAuthToken(authData['data']['token'] as String);
      }

      // Extract user data (based on backend response structure: data.user)
      User? user;
      if (authData['data'] != null && authData['data']['user'] != null) {
        user = User.fromJson(authData['data']['user'] as Map<String, dynamic>);
      }

      if (user != null) {
        _currentUser = user;
        await _saveUserToStorage(_currentUser!);
        return ApiResponse<User?>.success(data: user, message: authData['message'] as String?);
      }
    }

    return ApiResponse<User?>.error(message: 'Login failed');
  }

  /// User logout
  Future<ApiResponse<void>> logout() async {
    try {
      // Clear local data
      _currentUser = null;
      await _clearUserFromStorage();
      await _httpService.clearAuthToken();
      
      return ApiResponse<void>.success(message: AppConstants.logoutSuccessMessage);
    } catch (e) {
      return ApiResponse<void>.error(message: 'Logout failed');
    }
  }

  /// Get user profile
  Future<ApiResponse<User>> getUserProfile() async {
    final response = await _httpService.get(
      '/user/profile',
      fromJson: (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      _currentUser = response.data;
      await _saveUserToStorage(_currentUser!);
    }

    return response;
  }

  /// Update user profile
  Future<ApiResponse<User>> updateUserProfile({
    String? name,
    String? gender,
    String? fitnessGoal,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (gender != null) data['gender'] = gender;
    if (fitnessGoal != null) data['fitness_goal'] = fitnessGoal;

    final response = await _httpService.put(
      '/user/profile',
      data: data,
      fromJson: (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      _currentUser = response.data;
      await _saveUserToStorage(_currentUser!);
    }

    return response;
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      // Try to send verification code, if email exists it usually returns specific error
      final response = await sendVerificationCode(email: email, type: 'register');
      return !response.success && response.message?.contains('already exists') == true;
    } catch (e) {
      return false;
    }
  }

  /// Validate current user session
  Future<bool> validateSession() async {
    if (!isLoggedIn) return false;
    
    try {
      final response = await getUserProfile();
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Refresh user info
  Future<void> refreshUserInfo() async {
    if (isLoggedIn) {
      await getUserProfile();
    }
  }
}