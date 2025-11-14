/// API Configuration - Backend API settings
class ApiConfig {
  // Backend API base URL
  static const String baseUrl = 'http://localhost:8000/api';
  
  // API endpoints
  static const String authLogin = '/auth/login';
  static const String authSignup = '/auth/signup';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  
  static const String profileGet = '/profile';
  static const String profileUpdate = '/profile';
  
  static const String bookingGetServices = '/booking/services';
  static const String bookingCreate = '/booking/book';
  
  static const String notificationGet = '/notification';
  
  /// Get full URL for endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}

