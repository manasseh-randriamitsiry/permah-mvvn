class AppConstants {
  // API URLs
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.127:8000',
  );
  static const String apiBaseUrl2 = String.fromEnvironment(
    'API_BASE_URL_2',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Route Names
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String verifyResetCodeRoute = '/verify-reset-code';
  static const String resetPasswordRoute = '/reset-password';
  static const String myEventsRoute = '/my-events';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';
  static const String createEventRoute = '/create-event';
  static const String eventListRoute = '/event-list';

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
