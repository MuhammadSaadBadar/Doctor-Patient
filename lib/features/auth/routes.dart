import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/features/auth/repositories/auth_repository.dart';

class AppRoutes {
  // Splash screen - landing page
  static const String splash = '/splash';

  // Login screen
  static const String login = '/login';

  // Forgot password screen
  static const String forgotPassword = '/forgot-password';

  // Dashboard - main app page
  static const String dashboard = '/dashboard';

  // Appointments screen
  static const String appointments = '/appointments';

  // Patient detail screen
  static const String patientDetail = '/patient-detail';

  // Patient management screen
  static const String patientManagement = '/patient-management';

  // OTP verification screen (after login)
  static const String otpVerification = '/otp-verification';

  // Password reset screen
  static const String passwordReset = '/password-reset';

  // Settings screen
  static const String settings = '/settings';
}
