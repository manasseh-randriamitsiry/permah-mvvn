import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../model/api_response.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiService _apiService;
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  ForgotPasswordViewModel(this._authRepository, this._apiService);

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
    if (emailController.text.trim().isEmpty) {
      setError('Email is required');
      return false;
    }

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      setError('Please enter a valid email address');
      return false;
    }

    setError(null);
    return true;
  }

  Future<ApiResponse<void>> requestPasswordReset() async {
    if (!validateInputs()) {
      return ApiResponse.error(_error ?? 'Validation failed');
    }

    setLoading(true);
    setError(null);

    try {
      print('Requesting password reset for email: ${emailController.text.trim()}');
      final response = await _apiService.requestPasswordReset(
        emailController.text.trim(),
      );

      setLoading(false);
      if (response.success) {
        print('Password reset request successful');
        return response;
      }

      setError(response.message ?? 'Failed to send reset code');
      print('Password reset request failed: ${response.message}');
      return response;
    } catch (e) {
      setLoading(false);
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        setError(
            'Network error: Could not connect to the server. Please check your internet connection.');
      } else if (e.toString().contains('TimeoutException')) {
        setError('Network error: The connection timed out. Please try again.');
      } else {
        setError('An unexpected error occurred: ${e.toString()}');
      }
      print('Password reset request error: $e');
      return ApiResponse.error(_error ?? e.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
} 