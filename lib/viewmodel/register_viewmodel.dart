import 'package:flutter/material.dart';
import '../model/api_response.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  RegisterViewModel(this._authRepository);

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
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setError('All fields are required');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setError('Passwords do not match');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
      setError('Please enter a valid email');
      return false;
    }

    if (passwordController.text.length < 6) {
      setError('Password must be at least 6 characters');
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
    try {
      final response = await _authRepository.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
      
      setLoading(false);
      if (!response.success) {
        setError(response.message);
      }
      return response;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return ApiResponse.error(e.toString());
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