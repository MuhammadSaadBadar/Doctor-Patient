// lib/core/routes/app_routes.dart

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String passwordResetSuccess = '/password-reset-success';
  static const String changePassword = '/change-password';
  static const String dashboard = '/dashboard';
  static const String patients = '/patients';
  static const String patientDetail = '/patient-detail';
  static const String appointments = '/appointments';
  static const String dietPlans = '/diet-plans';
  static const String createDietPlan = '/create-diet-plan';
  static const String editDietPlan = '/edit-diet-plan';
  static const String settings = '/settings';
  static const String appointmentDetail = '/appointment-detail';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String paymentMethods = '/payment-methods';

  // ============ MEDICINE REMINDER ROUTES ============
  static const String medicineReminders = '/medicine-reminders';
  static const String createMedicineReminder = '/create-medicine-reminder';
  static const String editMedicineReminder = '/edit-medicine-reminder';
  // ==================================================
  static const String sendMessage = '/send-message';

  static const String notifications = '/notifications';
  static const String addPaymentMethod = '/add-payment-method';

  // ============ SOS ROUTES ============
  static const String sos = '/sos';
  static const String sosDetail = '/sos-detail';
  // ===================================

  // ============ HEALTH HISTORY ROUTES ============
  static const String bloodPressureHistory = '/blood-pressure-history';
  static const String bloodSugarHistory = '/blood-sugar-history';
  // ===============================================
}
