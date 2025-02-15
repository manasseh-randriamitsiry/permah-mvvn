import 'package:flutter/material.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';
import '../model/api_response.dart';
import '../common/util.dart';
import '../core/services/api_service.dart';
import '../core/services/api_config_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiConfigService _apiConfigService;
  final ApiService _apiService;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController customIpController = TextEditingController();

  bool _isLoading = false;
  User? _currentUser;
  String? _error;

  LoginViewModel(this._authRepository, this._apiService) 
      : _apiConfigService = ApiConfigService() {
    _loadCustomIp();
  }

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get error => _error;

  Future<void> _loadCustomIp() async {
    final savedIp = await getCustomIp();
    if (savedIp != null) {
      customIpController.text = savedIp;
    }
  }

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

    // Validate IP address format if provided
    final ipAddress = customIpController.text.trim();
    if (ipAddress.isNotEmpty) {
      // Split IP and port if port is provided
      final parts = ipAddress.split(':');
      final ip = parts[0];
      
      // Validate port if provided
      if (parts.length > 1) {
        try {
          final port = int.parse(parts[1]);
          if (port < 0 || port > 65535) {
            setError('Invalid port number. Port must be between 0 and 65535');
            return false;
          }
        } catch (e) {
          setError('Invalid port number format');
          return false;
        }
      }

      // Validate IP address
      final ipParts = ip.split('.');
      if (ipParts.length != 4) {
        setError('Please enter a valid IP address (e.g., 192.168.1.100:8000)');
        return false;
      }
      for (var part in ipParts) {
        try {
          final number = int.parse(part);
          if (number < 0 || number > 255) {
            setError('Please enter a valid IP address (e.g., 192.168.1.100:8000)');
            return false;
          }
        } catch (e) {
          setError('Please enter a valid IP address (e.g., 192.168.1.100:8000)');
          return false;
        }
      }
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
      // Update API configuration with new IP
      final customIp = customIpController.text.trim();
      await _apiConfigService.updateBaseUrl(customIp.isNotEmpty ? customIp : null);
      
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setLoading(false);
      if (response.success && response.data != null) {
        _currentUser = response.data;
        notifyListeners();
        return response;
      }

      setError(
          response.message ?? 'Login failed. Please check your credentials.');
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
    customIpController.dispose();
    super.dispose();
  }
}
