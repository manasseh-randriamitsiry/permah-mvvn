import 'package:flutter/material.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  User? _currentUser;

  LoginViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool validateInputs() {
    return usernameController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
  }

  Future<bool> login() async {
    if (!validateInputs()) {
      return false;
    }

    setLoading(true);
    try {
      final response = await _authRepository.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      setLoading(false);
      if (response.success && response.data != null) {
        _currentUser = response.data;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setLoading(false);
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
      return false;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
