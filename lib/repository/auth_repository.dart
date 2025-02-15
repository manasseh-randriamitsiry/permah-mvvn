import '../model/api_response.dart';
import '../model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthRepository {
  final SharedPreferences _prefs;
  User? _currentUser;
  static const String _userKey = 'user_data';

  AuthRepository._({
    required SharedPreferences prefs,
  }) : _prefs = prefs {
    _loadStoredUser();
  }

  static Future<AuthRepository> create({
    SharedPreferences? prefs,
  }) async {
    final sharedPrefs = prefs ?? await SharedPreferences.getInstance();
    return AuthRepository._(
      prefs: sharedPrefs,
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
    // Mock successful login for testing
    final user = User(
      id: 1,
      email: email,
      name: 'Test User',
    );

    await _saveAuthData(user);
    return ApiResponse.success(user);
  }

  Future<ApiResponse<User>> register(
      String name, String email, String password) async {
    // Mock successful registration
    final user = User(
      id: 1,
      email: email,
      name: name,
    );

    _currentUser = user;
    await _saveUser(user);
    return ApiResponse.success(user);
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

    final updatedUser = User(
      id: _currentUser!.id,
      email: email ?? _currentUser!.email,
      name: name ?? _currentUser!.name,
    );

    _currentUser = updatedUser;
    await _saveUser(updatedUser);
    return ApiResponse.success(updatedUser);
  }

  Future<bool> logout() async {
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
