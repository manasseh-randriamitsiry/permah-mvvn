import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../model/api_response.dart';

class VerifyResetCodeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiService _apiService;
  final String email;
  final TextEditingController codeController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  VerifyResetCodeViewModel(this._authRepository, this._apiService, this.email);

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
    if (codeController.text.trim().isEmpty) {
      setError('Verification code is required');
      return false;
    }

    // Validate code format (6 digits)
    if (!RegExp(r'^\d{6}$').hasMatch(codeController.text.trim())) {
      setError('Please enter a valid 6-digit code');
      return false;
    }

    setError(null);
    return true;
  }

  Future<ApiResponse<void>> verifyResetCode() async {
    if (!validateInputs()) {
      return ApiResponse.error(_error ?? 'Validation failed');
    }

    setLoading(true);
    setError(null);

    try {
      final response = await _apiService.verifyResetCode(
        email,
        codeController.text.trim(),
      );

      setLoading(false);
      if (response.success) {
        return response;
      }

      setError(response.message ?? 'Invalid verification code');
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

  Future<ApiResponse<void>> resendCode() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _apiService.requestPasswordReset(email);
      setLoading(false);
      return response;
    } catch (e) {
      setLoading(false);
      setError('Failed to resend code: ${e.toString()}');
      return ApiResponse.error(_error ?? e.toString());
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
} 