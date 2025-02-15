import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiConfigService extends ChangeNotifier {
  static final ApiConfigService _instance = ApiConfigService._internal();
  String _baseUrl = AppConstants.apiBaseUrl;
  
  factory ApiConfigService() {
    return _instance;
  }

  ApiConfigService._internal() {
    _loadSavedConfig();
  }

  String get baseUrl => _baseUrl;

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final customIp = prefs.getString('custom_ip');
    if (customIp != null && customIp.isNotEmpty) {
      if (customIp.contains(':')) {
        _baseUrl = 'http://$customIp';
      } else {
        _baseUrl = 'http://$customIp:8000';
      }
    } else {
      try {
        _baseUrl = AppConstants.apiBaseUrl;
      } catch (e) {
        _baseUrl = AppConstants.apiBaseUrl2;
      }
    }
    notifyListeners();
  }

  Future<void> updateBaseUrl(String? customIp) async {
    final prefs = await SharedPreferences.getInstance();
    if (customIp == null || customIp.isEmpty) {
      await prefs.remove('custom_ip');
      try {
        _baseUrl = AppConstants.apiBaseUrl;
      } catch (e) {
        _baseUrl = AppConstants.apiBaseUrl2;
      }
    } else {
      await prefs.setString('custom_ip', customIp);
      if (customIp.contains(':')) {
        _baseUrl = 'http://$customIp';
      } else {
        _baseUrl = 'http://$customIp:8000';
      }
    }
    notifyListeners();
  }
} 