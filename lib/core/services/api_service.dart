import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../model/api_response.dart';

class ApiService {
  final String baseUrl;
  String? _token;
  final Duration timeout = const Duration(seconds: 30);

  ApiService({required this.baseUrl});

  // Set the token after successful login
  void setToken(String token) {
    // Ensure token is stored with 'Bearer ' prefix if it doesn't already have it
    if (!token.startsWith('Bearer ')) {
      _token = 'Bearer $token';
    } else {
      _token = token;
    }
  }

  // Clear the token on logout
  void clearToken() {
    _token = null;
  }

  // Helper method to get headers
  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _token != null) {
      // Ensure token is properly formatted for Symfony JWT authentication
      if (!_token!.startsWith('Bearer ')) {
        headers['Authorization'] = 'Bearer $_token';
      } else {
        headers['Authorization'] = _token!;
      }
    }

    return headers;
  }

  // Helper method to handle API errors
  ApiResponse<T> _handleError<T>(dynamic e, {int? statusCode}) {
    if (e.toString().contains('SocketException') ||
        e.toString().contains('Connection refused')) {
      return ApiResponse.error(
        'Could not connect to the server. Please check if the server is running and try again.',
        statusCode: 503,
      );
    } else if (e.toString().contains('TimeoutException')) {
      return ApiResponse.error(
        'Request timed out. Please check your internet connection and try again.',
        statusCode: 408,
      );
    } else if (e.toString().contains('Method Not Allowed')) {
      return ApiResponse.error(
        'Server error: The request method is not allowed. Please contact support.',
        statusCode: 405,
      );
    } else {
      return ApiResponse.error(
        'An unexpected error occurred: ${e.toString()}',
        statusCode: statusCode ?? 500,
      );
    }
  }

  // Authentication endpoints
  Future<ApiResponse<Map<String, dynamic>>> login(
      String email, String password) async {
    final client = http.Client();
    try {
      print('Making login request to: $baseUrl/api/auth/login');
      print('Request body: ${json.encode({
            'email': email,
            'password': password,
          })}');

      final response = await client
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(timeout);

      print('Login response status code: ${response.statusCode}');
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Parsed response data: $data');

          // Check if we have the required data
          if (!data.containsKey('token') || !data.containsKey('user')) {
            print('Missing token or user in response');
            return ApiResponse.error(
              'Invalid server response: missing token or user data',
              statusCode: response.statusCode,
            );
          }

          // Set token from response body
          final token = data['token'] as String;
          print('Raw token from response: $token');
          setToken(token);
          print('Token after setting: $_token');

          // Also check for cookie token
          final cookies = response.headers['set-cookie'];
          if (cookies != null) {
            print('Received cookies: $cookies');
            final bearerCookie = cookies.split(';').firstWhere(
                  (cookie) => cookie.trim().startsWith('BEARER='),
                  orElse: () => '',
                );
            if (bearerCookie.isNotEmpty) {
              final cookieToken = bearerCookie.split('=')[1];
              print('Found BEARER cookie token: $cookieToken');
              // If we have a cookie token, use it instead of the body token
              setToken(cookieToken);
              print('Final token after cookie check: $_token');
            }
          }

          return ApiResponse.success(data);
        } catch (e) {
          print('Error parsing successful response: $e');
          return ApiResponse.error(
            'Error parsing server response: ${e.toString()}',
            statusCode: response.statusCode,
          );
        }
      } else {
        try {
          final data = json.decode(response.body);
          final errorMessage =
              data['message'] ?? 'Login failed. Please check your credentials.';
          print('Error response from server: $errorMessage');
          return ApiResponse.error(errorMessage,
              statusCode: response.statusCode);
        } catch (e) {
          print('Error parsing error response: $e');
          return ApiResponse.error(
            'Login failed. Please check your credentials.',
            statusCode: response.statusCode,
          );
        }
      }
    } on TimeoutException {
      print('Request timed out');
      return ApiResponse.error(
        'Request timed out. Please check your internet connection and try again.',
        statusCode: 408,
      );
    } catch (e) {
      print('Login error: $e');
      return _handleError(e);
    } finally {
      client.close();
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register(
      String name, String email, String password) async {
    final client = http.Client();
    try {
      print('Making register request to: $baseUrl/api/auth/register');
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: _getHeaders(requiresAuth: false),
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(timeout);

      print('Register response status code: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 405) {
        return ApiResponse.error(
          'Server error: Register endpoint not properly configured. Please contact support.',
          statusCode: 405,
        );
      }

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(data);
      }

      String errorMessage = data['message'] ?? 'Registration failed';
      if (response.statusCode == 409 || errorMessage.contains('duplicate')) {
        errorMessage =
            'This email is already registered. Please use a different email or try logging in.';
      }

      return ApiResponse.error(errorMessage, statusCode: response.statusCode);
    } on TimeoutException {
      return ApiResponse.error(
        'Request timed out. Please check your internet connection and try again.',
        statusCode: 408,
      );
    } catch (e) {
      return _handleError(e);
    } finally {
      client.close();
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
      final headers = _getHeaders();
      print('Fetching events with headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/events'),
        headers: headers,
      );

      print('Get events response status: ${response.statusCode}');
      print('Get events response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return ApiResponse.success(data);
        } else {
          print('Unexpected response format: $data');
          return ApiResponse.error('Unexpected response format from server');
        }
      }

      try {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data['message'] ?? 'Failed to fetch events',
          statusCode: response.statusCode,
        );
      } catch (e) {
        print('Error parsing error response: $e');
        return ApiResponse.error('Failed to fetch events');
      }
    } catch (e) {
      print('Get events error: $e');
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
    required String imageUrl,
  }) async {
    try {
      final headers = _getHeaders();
      print('Creating event with headers: $headers');
      print('Token value: $_token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/events'),
        headers: headers,
        body: json.encode({
          'title': title,
          'description': description,
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
          'location': location,
          'available_places': availablePlaces,
          'price': price,
          'image_url': imageUrl,
        }),
      );

      print('Create event response status: ${response.statusCode}');
      print('Create event response body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        return ApiResponse.success(data);
      }

      return ApiResponse.error(
        data['message'] ?? 'Failed to create event',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('Create event error: $e');
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
    required String imageUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'image_url': imageUrl,
      };
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (startDate != null)
        body['startDate'] = startDate.toUtc().toIso8601String();
      if (endDate != null) body['endDate'] = endDate.toUtc().toIso8601String();
      if (location != null) body['location'] = location;
      if (availablePlaces != null) body['available_places'] = availablePlaces;
      if (price != null) body['price'] = price;

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

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(null);
      }

      try {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data['message'] ?? 'Failed to delete event',
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error(
          'Failed to delete event',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<void>> joinEvent(int id) async {
    try {
      print('Joining event with ID: $id');
      print('Headers: ${_getHeaders()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/events/$id/join'),
        headers: _getHeaders(),
      );

      print('Join event response status: ${response.statusCode}');
      print('Join event response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null);
      }

      try {
        final data = json.decode(response.body);
        final errorMessage = data['message'] ?? 'Failed to join event';
        print('Error joining event: $errorMessage');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      } catch (e) {
        print('Error parsing error response: $e');
        return ApiResponse.error('Failed to join event', statusCode: response.statusCode);
      }
    } catch (e) {
      print('Network error joining event: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<void>> leaveEvent(int id) async {
    try {
      print('Leaving event with ID: $id');
      print('Headers: ${_getHeaders()}');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/events/$id/leave'),
        headers: _getHeaders(),
      );

      print('Leave event response status: ${response.statusCode}');
      print('Leave event response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(null);
      }

      try {
        final data = json.decode(response.body);
        final errorMessage = data['message'] ?? 'Failed to leave event';
        print('Error leaving event: $errorMessage');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      } catch (e) {
        print('Error parsing error response: $e');
        return ApiResponse.error('Failed to leave event', statusCode: response.statusCode);
      }
    } catch (e) {
      print('Network error leaving event: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // New methods for event endpoints
  Future<ApiResponse<List<dynamic>>> getUpcomingEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events/upcoming'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return ApiResponse.success(data);
        }
        return ApiResponse.error('Unexpected response format from server');
      }

      try {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data['message'] ?? 'Failed to fetch upcoming events',
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error('Failed to fetch upcoming events');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<dynamic>>> getPastEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events/past'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return ApiResponse.success(data);
        }
        return ApiResponse.error('Unexpected response format from server');
      }

      try {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data['message'] ?? 'Failed to fetch past events',
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error('Failed to fetch past events');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<dynamic>>> searchEvents({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    double? minPrice,
    double? maxPrice,
    bool? hasAvailablePlaces,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (query != null) queryParams['q'] = query;
      if (startDate != null) queryParams['start_date'] = startDate.toUtc().toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toUtc().toIso8601String();
      if (location != null) queryParams['location'] = location;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (hasAvailablePlaces != null) queryParams['has_available_places'] = hasAvailablePlaces ? '1' : '0';

      final uri = Uri.parse('$baseUrl/api/events/search').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return ApiResponse.success(data);
        }
        return ApiResponse.error('Unexpected response format from server');
      }

      try {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data['message'] ?? 'Failed to search events',
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error('Failed to search events');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getEventStatistics(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events/$eventId/statistics'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data);
      }

      try {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data['message'] ?? 'Failed to fetch event statistics',
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error('Failed to fetch event statistics');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getEventParticipants(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events/$eventId/participants'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data);
      }

      try {
        final data = json.decode(response.body);
        return ApiResponse.error(
          data['message'] ?? 'Failed to fetch event participants',
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error('Failed to fetch event participants');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
