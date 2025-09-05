import '../constants/app_constants.dart';

/// Form validation utility class
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email address';
    }
    
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return 'Invalid email format';
    }
    
    return null;
  }
  
  /// Validate password format
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    
    if (!RegExp(AppConstants.passwordRegex).hasMatch(value)) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please enter password again';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validate verification code
  static String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter verification code';
    }
    
    if (value.length != 6) {
      return 'Verification code should be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Invalid verification code format';
    }
    
    return null;
  }
  
  /// Validate user name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter name';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.trim().length > 20) {
      return 'Name cannot exceed 20 characters';
    }
    
    return null;
  }
  
  /// Validate exercise scenario description
  static String? validateScenario(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please describe exercise scenario';
    }
    
    if (value.trim().length < 5) {
      return 'Scenario description must be at least 5 characters';
    }
    
    if (value.trim().length > 200) {
      return 'Scenario description cannot exceed 200 characters';
    }
    
    return null;
  }
  
  /// Validate question content
  static String? validateQuestion(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter question content';
    }
    
    if (value.trim().length < 3) {
      return 'Question content must be at least 3 characters';
    }
    
    if (value.trim().length > 500) {
      return 'Question content cannot exceed 500 characters';
    }
    
    return null;
  }
  
  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return 'Invalid phone number format';
    }
    
    return null;
  }
  
  /// Validate number range
  static String? validateNumberRange(String? value, int min, int max, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName must be a number';
    }
    
    if (number < min || number > max) {
      return '$fieldName must be between $min-$max';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    
    return null;
  }
  
  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }
  
  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    
    return null;
  }
  
  /// Combine multiple validators
  static String? combineValidators(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}