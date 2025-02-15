import 'package:flutter/material.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';
import '../model/api_response.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  User? _currentUser;
  String? _error;

  LoginViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      setError('Please enter a valid email address');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      setError('Password is required');
      return false;
    }
    setError(null);
    return true;
  }

  Future<bool> login() async {
    if (!validateInputs()) {
      return false;
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
        _currentUser = response.data;
        notifyListeners();
        return true;
      }

      setError(
          response.message ?? 'Login failed. Please check your credentials.');
      return false;
    } catch (e) {
      setLoading(false);
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        setError(
            'Network error: Could not connect to the server. Please check your internet connection and try again.');
      } else if (e.toString().contains('TimeoutException')) {
        setError('Network error: The connection timed out. Please try again.');
      } else {
        setError('An unexpected error occurred: ${e.toString()}');
      }
      return false;
    }
  }

  Future<bool> logout() async {
    setLoading(true);
    try {
      final success = await _authRepository.logout();
      setLoading(false);
      if (success) {
        _currentUser = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      setLoading(false);
      setError('Failed to logout: ${e.toString()}');
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
