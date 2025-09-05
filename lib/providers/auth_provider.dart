import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';

/// Authentication state management Provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  /// Current user
  User? get user => _user;
  
  /// Whether logged in
  bool get isLoggedIn => _user != null;
  
  /// Whether loading
  bool get isLoading => _isLoading;
  
  /// Error message
  String? get errorMessage => _errorMessage;
  
  /// Whether user profile is complete
  bool get isProfileComplete => _user?.isProfileComplete ?? false;
  
  /// Initialize authentication Provider
  Future<void> init() async {
    await _authService.init();
    _user = _authService.currentUser;
    notifyListeners();
  }
  
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
  
  /// Send verification code
  Future<bool> sendVerificationCode(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _authService.sendVerificationCode(email: email);
      
      if (!response.success) {
        _setError(response.message ?? 'Failed to send verification code');
      }
      
      return response.success;
    } catch (e) {
      _setError('Error occurred while sending verification code');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// User registration
  Future<bool> register({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        verificationCode: verificationCode,
      );
      
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Error occurred during registration');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// User login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Error occurred during login');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _user = null;
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Error occurred during logout');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? gender,
    String? fitnessGoal,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _authService.updateUserProfile(
        name: name,
        gender: gender,
        fitnessGoal: fitnessGoal,
      );
      
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Update failed');
        return false;
      }
    } catch (e) {
      _setError('Error occurred while updating user information');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refresh user information
  Future<void> refreshUser() async {
    if (!isLoggedIn) return;
    
    _setLoading(true);
    
    try {
      final response = await _authService.getUserProfile();
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      // Refresh failure does not show error message, handle silently
    } finally {
      _setLoading(false);
    }
  }
  
  /// Validate session validity
  Future<bool> validateSession() async {
    if (!isLoggedIn) return false;
    
    try {
      return await _authService.validateSession();
    } catch (e) {
      return false;
    }
  }
  
  /// Check if email is already registered
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authService.checkEmailExists(email);
    } catch (e) {
      return false;
    }
  }
}