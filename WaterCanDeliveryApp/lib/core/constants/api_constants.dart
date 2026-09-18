class ApiConstants {
  // Tip: When testing on phone via same Wi-Fi, use your PC's IP (e.g. http://10.89.84.138:3000)
  // When using a public tunnel (like localtunnel or ngrok), set the https:// URL here!
  static const String baseUrl = 'https://watercan-jrk0.onrender.com';

  static String get sendOtp => '$baseUrl/api/auth/send-otp';
  static String get verifyOtp => '$baseUrl/api/auth/verify-otp';
  static String get register => '$baseUrl/api/auth/register';
  static String get login => '$baseUrl/api/auth/login';
  static String get updatePhone => '$baseUrl/api/auth/phone';
  static String get updateAddress => '$baseUrl/api/auth/address';
  static String get orders => '$baseUrl/api/orders';
}
