import '../model/api_response.dart';
import '../model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/services/api_service.dart';

class AuthRepository {
  final SharedPreferences _prefs;
  final ApiService _apiService;
  User? _currentUser;
  static const String _userKey = 'user_data';

  AuthRepository._({
    required SharedPreferences prefs,
    required ApiService apiService,
  })  : _prefs = prefs,
        _apiService = apiService {
    _loadStoredUser();
  }

  static Future<AuthRepository> create({
    SharedPreferences? prefs,
    required String baseUrl,
  }) async {
    final sharedPrefs = prefs ?? await SharedPreferences.getInstance();
    final apiService = ApiService(baseUrl: baseUrl);
    return AuthRepository._(
      prefs: sharedPrefs,
      apiService: apiService,
    );
  }

  User? get currentUser => _currentUser;

  void _loadStoredUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(json.decode(userJson));
      } catch (e) {
        _clearAuthData();
      }
    }
  }

  Future<ApiResponse<User>> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!['user']);
      await _saveAuthData(user);
      return ApiResponse.success(user);
    }
    return ApiResponse.error(response.message ?? 'Login failed');
  }

  Future<ApiResponse<User>> register(
      String name, String email, String password) async {
    final response = await _apiService.register(name, email, password);
    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!['user']);
      _currentUser = user;
      await _saveUser(user);
      return ApiResponse.success(user);
    }
    return ApiResponse.error(response.message ?? 'Registration failed');
  }

  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (_currentUser == null) {
      return ApiResponse.error('Not logged in');
    }

    final response = await _apiService.updateProfile(
      name: name,
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!['user']);
      _currentUser = user;
      await _saveUser(user);
      return ApiResponse.success(user);
    }
    return ApiResponse.error(response.message ?? 'Profile update failed');
  }

  Future<bool> logout() async {
    _apiService.clearToken();
    await _clearAuthData();
    return true;
  }

  Future<void> _saveAuthData(User user) async {
    _currentUser = user;
    await _saveUser(user);
  }

  Future<void> _saveUser(User user) async {
    await _prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> _clearAuthData() async {
    _currentUser = null;
    await _prefs.remove(_userKey);
  }
}
