import 'package:flutter/material.dart';
import '../model/api_response.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _error;
  User? _user;

  ProfileViewModel(this._authRepository) {
    _user = _authRepository.currentUser;
    if (_user != null) {
      nameController.text = _user!.name;
      emailController.text = _user!.email;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> logout() async {
    setLoading(true);
    try {
      final success = await _authRepository.logout();
      setLoading(false);
      return success;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  bool validateInputs({bool isChangingPassword = false}) {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      setError('Name and email are required');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      setError('Please enter a valid email');
      return false;
    }

    if (isChangingPassword) {
      if (currentPasswordController.text.isEmpty ||
          newPasswordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        setError('All password fields are required');
        return false;
      }

      if (newPasswordController.text != confirmPasswordController.text) {
        setError('New passwords do not match');
        return false;
      }

      if (newPasswordController.text.length < 6) {
        setError('Password must be at least 6 characters');
        return false;
      }
    }

    setError(null);
    return true;
  }

  Future<ApiResponse<User>> updateProfile(
      {bool isChangingPassword = false}) async {
    if (!validateInputs(isChangingPassword: isChangingPassword)) {
      return ApiResponse.error(_error ?? 'Validation failed');
    }

    setLoading(true);
    try {
      final response = await _authRepository.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        currentPassword:
            isChangingPassword ? currentPasswordController.text : null,
        newPassword: isChangingPassword ? newPasswordController.text : null,
      );

      setLoading(false);
      if (response.success && response.data != null) {
        _user = response.data;
        if (!isChangingPassword) {
          nameController.text = _user!.name;
          emailController.text = _user!.email;
        } else {
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        }
        notifyListeners();
      } else {
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
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
