class AppConstants {
  // API URLs
  static const String apiBaseUrl = 'http://localhost:8000';

  // Route Names
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String signupRoute = '/signup';

  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 350;

  // Error Messages
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword =
      'Password must be between $minPasswordLength and $maxPasswordLength characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String requiredField = 'This field is required';
}
