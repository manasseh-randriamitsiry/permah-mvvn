import 'package:flutter/material.dart';
import '../model/api_response.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiService _apiService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  RegisterViewModel(this._authRepository, this._apiService);

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
    // Check for empty fields with specific messages
    if (nameController.text.trim().isEmpty) {
      setError('Name is required');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      setError('Email is required');
      return false;
    }
    if (passwordController.text.isEmpty) {
      setError('Password is required');
      return false;
    }
    if (confirmPasswordController.text.isEmpty) {
      setError('Please confirm your password');
      return false;
    }

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      setError('Please enter a valid email address');
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

  Future<ApiResponse<User>> register() async {
    if (!validateInputs()) {
      return ApiResponse.error(_error ?? 'Validation failed');
    }

    setLoading(true);
    setError(null);

    try {
      final response = await _authRepository.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setLoading(false);
      if (response.success && response.data != null) {
        return response;
      }

      setError(response.message ?? 'Registration failed');
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
