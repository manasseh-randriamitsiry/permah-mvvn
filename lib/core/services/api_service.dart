import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../model/api_response.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({required this.baseUrl});

  // Set the token after successful login
  void setToken(String token) {
    _token = token;
  }

  // Clear the token on logout
  void clearToken() {
    _token = null;
  }

  // Helper method to get headers
  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Authentication endpoints
  Future<ApiResponse<Map<String, dynamic>>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _getHeaders(requiresAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        // Extract token from cookie if present
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          final bearerCookie = cookies.split(';').firstWhere(
                (cookie) => cookie.trim().startsWith('BEARER='),
                orElse: () => '',
              );
          if (bearerCookie.isNotEmpty) {
            final token = bearerCookie.split('=')[1];
            setToken(token);
          }
        }

        // Also set token from response body if present
        if (data['token'] != null) {
          setToken(data['token']);
        }

        return ApiResponse.success(data);
      }

      return ApiResponse.error(
        data['message'] ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _getHeaders(requiresAuth: false),
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(data);
      }

      return ApiResponse.error(
        data['message'] ?? 'Registration failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (currentPassword != null) body['current_password'] = currentPassword;
      if (newPassword != null) body['new_password'] = newPassword;

      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: _getHeaders(),
        body: json.encode(body),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(data);
      }

      return ApiResponse.error(
        data['message'] ?? 'Profile update failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Event endpoints
  Future<ApiResponse<List<dynamic>>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events'),
        headers: _getHeaders(),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(data as List<dynamic>);
      }

      return ApiResponse.error(
        data['message'] ?? 'Failed to fetch events',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getEvent(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events/$id'),
        headers: _getHeaders(),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(data);
      }

      return ApiResponse.error(
        data['message'] ?? 'Failed to fetch event',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    required int availablePlaces,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/events'),
        headers: _getHeaders(),
        body: json.encode({
          'title': title,
          'description': description,
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
          'location': location,
          'available_places': availablePlaces,
          'price': price,
          if (imageUrl != null) 'image_url': imageUrl,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(data);
      }

      return ApiResponse.error(
        data['message'] ?? 'Failed to create event',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateEvent(
    int id, {
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    int? availablePlaces,
    double? price,
    String? imageUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (startDate != null)
        body['startDate'] = startDate.toUtc().toIso8601String();
      if (endDate != null) body['endDate'] = endDate.toUtc().toIso8601String();
      if (location != null) body['location'] = location;
      if (availablePlaces != null) body['available_places'] = availablePlaces;
      if (price != null) body['price'] = price;
      if (imageUrl != null) body['image_url'] = imageUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/api/events/$id'),
        headers: _getHeaders(),
        body: json.encode(body),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(data);
      }

      return ApiResponse.error(
        data['message'] ?? 'Failed to update event',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<void>> deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/events/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }

      final data = json.decode(response.body);
      return ApiResponse.error(
        data['message'] ?? 'Failed to delete event',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<void>> joinEvent(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/events/$id/join'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }

      final data = json.decode(response.body);
      return ApiResponse.error(
        data['message'] ?? 'Failed to join event',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<void>> leaveEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/events/$id/leave'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }

      final data = json.decode(response.body);
      return ApiResponse.error(
        data['message'] ?? 'Failed to leave event',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
