import 'package:flutter/material.dart';
import '../common/util.dart';
import '../model/api_response.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';
import '../core/services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiService _apiService;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  LoginViewModel(this._authRepository, this._apiService);

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
    if (passwordController.text.isEmpty) {
      setError('Password is required');
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

  Future<ApiResponse<User>> login() async {
    if (!validateInputs()) {
      return ApiResponse.error(_error ?? 'Validation failed');
    }

    setLoading(true);
    setError(null);

    try {
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setLoading(false);
      if (response.success && response.data != null) {
        return response;
      }

      setError(response.message ?? 'Login failed');
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
