// lib/features/routes.dart - Complete routes file

import 'package:doctor/features/appointments/providers/appointment_detail_binding.dart';
import 'package:doctor/features/appointments/screens/appointment_details_screen.dart';
import 'package:doctor/features/appointments/providers/appointment_binding.dart';
import 'package:doctor/features/appointments/screens/appointment_screen.dart';
import 'package:doctor/features/auth/providers/change_password_binding.dart';
import 'package:doctor/features/auth/providers/forgot_password_binding.dart';
import 'package:doctor/features/auth/providers/login_binding.dart';
import 'package:doctor/features/auth/providers/otp_verification_binding.dart';
import 'package:doctor/features/auth/providers/reset_password_binding.dart';
import 'package:doctor/features/auth/providers/splash_binding.dart';
import 'package:doctor/features/auth/screens/change_password_screen.dart';
import 'package:doctor/features/auth/screens/forgot_password_screen.dart';
import 'package:doctor/features/auth/screens/login_screen.dart';
import 'package:doctor/features/auth/screens/otp_verification_screen.dart';
import 'package:doctor/features/auth/screens/reset_password_screen.dart';
import 'package:doctor/features/auth/screens/splash_screen.dart';
import 'package:doctor/features/dashboard/providers/dashboard_binding.dart';
import 'package:doctor/features/dashboard/screens/dashboard_screen.dart';
import 'package:doctor/features/emergency/providers/sos_binding.dart';
import 'package:doctor/features/emergency/providers/sos_detail_binding.dart';
import 'package:doctor/features/emergency/screens/sos_detail_screen.dart';
import 'package:doctor/features/emergency/screens/sos_screen.dart';
import 'package:doctor/features/notifications/providers/notification_binding.dart';
import 'package:doctor/features/notifications/screens/notification_screen.dart';
import 'package:doctor/features/patient/providers/create_diet_plan_binding.dart';
import 'package:doctor/features/patient/providers/diet_plans_binding.dart';
import 'package:doctor/features/patient/providers/edit_diet_plan_binding.dart';
import 'package:doctor/features/patient/providers/patient_binding.dart';
import 'package:doctor/features/patient/providers/patient_detail_binding.dart';
import 'package:doctor/features/patient/providers/send_message_binding.dart';
import 'package:doctor/features/patient/providers/blood_pressure_history_binding.dart';
import 'package:doctor/features/patient/providers/blood_sugar_history_binding.dart';
import 'package:doctor/features/patient/screens/create_edit_diet_plan_screen.dart';
import 'package:doctor/features/patient/screens/diet_plans_screen.dart';
import 'package:doctor/features/patient/screens/patient_detail_screen.dart';
import 'package:doctor/features/patient/screens/patient_management_screen.dart';
import 'package:doctor/features/patient/screens/send_message_screen.dart';
import 'package:doctor/features/patient/screens/blood_pressure_history_screen.dart';
import 'package:doctor/features/patient/screens/blood_sugar_history_screen.dart';
import 'package:doctor/features/profile/providers/add_payment_method_binding.dart';
import 'package:doctor/features/profile/providers/edit_profile_binding.dart';
import 'package:doctor/features/profile/providers/profile_binding.dart';
import 'package:doctor/features/profile/screens/add_payment_method_screen.dart';
import 'package:doctor/features/profile/screens/profile_screen.dart';
import 'package:doctor/features/profile/screens/edit_profile_screen.dart';
import 'package:doctor/features/settings/screens/payment_method_screen.dart';
import 'package:doctor/features/settings/screens/settings_screen.dart';

// ============ MEDICINE REMINDER IMPORTS ============
import 'package:doctor/features/patient/providers/medicine_reminders_binding.dart';
import 'package:doctor/features/patient/providers/create_medicine_reminder_binding.dart';
import 'package:doctor/features/patient/providers/edit_medicine_reminder_binding.dart';
import 'package:doctor/features/patient/screens/medicine_reminders_screen.dart';
import 'package:doctor/features/patient/screens/create_edit_medicine_reminder_screen.dart';
// ===================================================

import 'package:get/get.dart';
import '../routes/app_routes.dart';

class Routes {
  static final List<GetPage> _pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.patients,
      page: () => PatientManagementScreen(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.patientDetail,
      page: () => PatientDetailScreen(),
      binding: PatientDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.appointments,
      page: () => const AppointmentScreen(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.dietPlans,
      page: () => DietPlansScreen(),
      binding: DietPlansBinding(),
    ),
    GetPage(
      name: AppRoutes.createDietPlan,
      page: () => const CreateEditDietPlanScreen(),
      binding: CreateDietPlanBinding(),
    ),
    GetPage(
      name: AppRoutes.editDietPlan,
      page: () => CreateEditDietPlanScreen(isEditing: true),
      binding: EditDietPlanBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.appointmentDetail,
      page: () => const AppointmentDetailsScreen(),
      binding: AppointmentDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentMethods,
      page: () => const PaymentMethodsScreen(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.medicineReminders,
      page: () => const MedicineRemindersScreen(),
      binding: MedicineRemindersBinding(),
    ),
    GetPage(
      name: AppRoutes.createMedicineReminder,
      page: () => const CreateEditMedicineReminderScreen(),
      binding: CreateMedicineReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.editMedicineReminder,
      page: () => const CreateEditMedicineReminderScreen(isEditing: true),
      binding: EditMedicineReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.sendMessage,
      page: () => const SendMessageScreen(),
      binding: SendMessageBinding(),
    ),

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ), // ==================================================
    GetPage(
      name: AppRoutes.addPaymentMethod,
      page: () => const AddPaymentMethodScreen(),
      binding: AddPaymentMethodBinding(),
    ),
    GetPage(
      name: AppRoutes.sos,
      page: () => const SosScreen(),
      binding: SosBinding(),
    ),
    GetPage(
      name: AppRoutes.sosDetail,
      page: () => const SosDetailScreen(),
      binding: SosDetailBinding(),
    ),

    // ============ HEALTH HISTORY ROUTES ============
    GetPage(
      name: AppRoutes.bloodPressureHistory,
      page: () => const BloodPressureHistoryScreen(),
      binding: BloodPressureHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.bloodSugarHistory,
      page: () => const BloodSugarHistoryScreen(),
      binding: BloodSugarHistoryBinding(),
    ),
    // ===============================================
  ];

  static List<GetPage> get pages => _pages;
}
