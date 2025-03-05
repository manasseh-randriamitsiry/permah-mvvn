import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../model/api_response.dart';
import '../core/constants/app_constants.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiService _apiService;
  final String email;
  final String code;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  ResetPasswordViewModel(this._authRepository, this._apiService, this.email, this.code);

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  bool validateInputs() {
    if (passwordController.text.isEmpty) {
      print('Validation failed: Password is empty');
      setError('Password is required');
      return false;
    }
    if (confirmPasswordController.text.isEmpty) {
      print('Validation failed: Confirm password is empty');
      setError('Please confirm your password');
      return false;
    }

    // Validate password length
    if (passwordController.text.length < AppConstants.minPasswordLength) {
      print('Validation failed: Password length ${passwordController.text.length} is less than ${AppConstants.minPasswordLength}');
      setError(
          'Password must be at least ${AppConstants.minPasswordLength} characters');
      return false;
    }

    // Validate password complexity
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$')
        .hasMatch(passwordController.text)) {
      print('Validation failed: Password does not meet complexity requirements');
      print('Password entered: ${passwordController.text}');
      setError('Password must contain at least one letter and one number');
      return false;
    }

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      print('Validation failed: Passwords do not match');
      print('Password: ${passwordController.text}');
      print('Confirm Password: ${confirmPasswordController.text}');
      setError('Passwords do not match');
      return false;
    }

    print('Password validation passed successfully');
    setError(null);
    return true;
  }

  Future<ApiResponse<void>> resetPassword() async {
    print('Starting password reset process...');
    print('Email: $email');
    print('Code length: ${code.length}');
    
    if (!validateInputs()) {
      print('Validation failed: ${_error ?? 'Unknown validation error'}');
      return ApiResponse.error(_error ?? 'Validation failed');
    }
    print('Validation passed successfully');

    setLoading(true);
    setError(null);

    try {
      print('Making API call to reset password...');
      final response = await _apiService.resetPassword(
        email,
        code,
        passwordController.text,
      );
      print('API Response received: ${response.success} - ${response.message}');

      setLoading(false);
      if (response.success) {
        print('Password reset successful');
        return response;
      }

      final errorMessage = response.message ?? 'Failed to reset password';
      print('Password reset failed: $errorMessage');
      if (response.statusCode == 401) {
        setError('Invalid or expired reset code. Please request a new code.');
      } else if (response.statusCode == 400) {
        setError('Invalid password format or reset request. Please try again.');
      } else if (response.statusCode == 404) {
        setError('User not found or reset code invalid. Please request a new code.');
      } else {
        setError(errorMessage);
      }
      return ApiResponse.error(_error ?? errorMessage, statusCode: response.statusCode);
    } catch (e) {
      print('Exception occurred during password reset: $e');
      setLoading(false);
      String errorMessage;
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage = 'Network error: Could not connect to the server. Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Network error: The request timed out. Please try again.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again later.';
      }
      print('Error details: $errorMessage');
      setError(errorMessage);
      return ApiResponse.error(errorMessage);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
} 