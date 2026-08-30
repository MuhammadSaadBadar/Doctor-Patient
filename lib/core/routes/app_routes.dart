// lib/core/routes/app_routes.dart

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String passwordResetSuccess = '/password-reset-success';
  static const String changePassword = '/change-password';
  static const String docdashboard = '/dashboard';
  static const String docpatients = '/patients';
  static const String docpatientDetail = '/patient-detail';
  static const String docappointments = '/appointments';
  static const String docdietPlans = '/diet-plans';
  static const String doccreateDietPlan = '/create-diet-plan';
  static const String doceditDietPlan = '/edit-diet-plan';
  static const String docsettings = '/settings';
  static const String docappointmentDetail = '/appointment-detail';
  static const String docprofile = '/profile';
  static const String doceditProfile = '/edit-profile';
  static const String docpaymentMethods = '/payment-methods';

  // ============ MEDICINE REMINDER ROUTES ============
  static const String docmedicineReminders = '/medicine-reminders';
  static const String doccreateMedicineReminder = '/create-medicine-reminder';
  static const String doceditMedicineReminder = '/edit-medicine-reminder';
  // ==================================================
  static const String docsendMessage = '/send-message';

  static const String docnotifications = '/notifications';
  static const String docaddPaymentMethod = '/add-payment-method';

  // ============ SOS ROUTES ============
  static const String docsos = '/sos';
  static const String docsosDetail = '/sos-detail';
  // ===================================

  // ============ HEALTH HISTORY ROUTES ============
  static const String docbloodPressureHistory = '/blood-pressure-history';
  static const String docbloodSugarHistory = '/blood-sugar-history';
  // ===============================================
  static const String dockickCountHistory = '/kick-count-history';

  // ============ PATIENT DASHBOARD ROUTES ============
  static const String patientDashboard = '/patient/dashboard';
  static const String patientSymptoms = '/patient/symptoms';
  static const String patientWaterIntake = '/patient/water-intake';
  static const String patientWaterIntakeHistory = '/patient/water-intake/history';
  static const String patientKickCount = '/patient/kick-count';
  static const String patientKickCountHistory = '/patient/kick-count/history';
  static const String patientVitals = '/patient/vitals';
  static const String patientDietPlanDetail = '/patient/diet-plan';
  static const String patientAppointmentDetail = '/patient/appointment-detail';
  // ===============================================

  // ============ PATIENT DOCTORS ROUTES ============
  static const String findDoctors = '/find-doctors';
  static const String doctorDetail = '/doctor';
  static const String bookAppointment = '/book-appointment';
  // ===============================================
}
