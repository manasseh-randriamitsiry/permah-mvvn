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
      setError('Password is required');
      return false;
    }
    if (confirmPasswordController.text.isEmpty) {
      setError('Please confirm your password');
      return false;
    }

    // Validate password length
    if (passwordController.text.length < AppConstants.minPasswordLength) {
      setError(
          'Password must be at least ${AppConstants.minPasswordLength} characters');
      return false;
    }

    // Validate password complexity
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$')
        .hasMatch(passwordController.text)) {
      setError('Password must contain at least one letter and one number');
      return false;
    }

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      setError('Passwords do not match');
      return false;
    }

    setError(null);
    return true;
  }

  Future<ApiResponse<void>> resetPassword() async {
    if (!validateInputs()) {
      return ApiResponse.error(_error ?? 'Validation failed');
    }

    setLoading(true);
    setError(null);

    try {
      final response = await _apiService.resetPassword(
        email,
        code,
        passwordController.text,
      );

      setLoading(false);
      if (response.success) {
        return response;
      }

      setError(response.message ?? 'Failed to reset password');
      return response;
    } catch (e) {
      setLoading(false);
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        setError(
            'Network error: Could not connect to the server. Please check your IP address and make sure the server is running.');
      } else if (e.toString().contains('TimeoutException')) {
        setError('Network error: The connection timed out. Please try again.');
      } else {
        setError('An unexpected error occurred: ${e.toString()}');
      }
      return ApiResponse.error(_error ?? e.toString());
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
} 