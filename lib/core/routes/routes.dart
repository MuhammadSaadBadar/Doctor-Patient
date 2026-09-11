// lib/features/routes.dart - Complete routes file

import 'package:doctor/doctor/features/appointments/bindings/doc_appointment_binding.dart';
import 'package:doctor/doctor/features/appointments/bindings/doc_appointment_detail_binding.dart';
import 'package:doctor/doctor/features/appointments/screens/doc_appointment_details_screen.dart';
import 'package:doctor/doctor/features/appointments/screens/doc_appointment_screen.dart';
import 'package:doctor/doctor/features/auth/bindings/change_password_binding.dart';
import 'package:doctor/doctor/features/auth/bindings/forgot_password_binding.dart';
import 'package:doctor/doctor/features/auth/bindings/login_binding.dart';
import 'package:doctor/doctor/features/auth/bindings/otp_verification_binding.dart';
import 'package:doctor/doctor/features/auth/bindings/patient_register_binding.dart';
import 'package:doctor/doctor/features/auth/bindings/reset_password_binding.dart';
import 'package:doctor/doctor/features/auth/bindings/splash_binding.dart';
import 'package:doctor/doctor/features/auth/screens/change_password_screen.dart';
import 'package:doctor/doctor/features/auth/screens/forgot_password_screen.dart';
import 'package:doctor/doctor/features/auth/screens/login_screen.dart';
import 'package:doctor/doctor/features/auth/screens/otp_verification_screen.dart';
import 'package:doctor/doctor/features/auth/screens/password_reset_success_screen.dart';
import 'package:doctor/doctor/features/auth/screens/patient_register_screen.dart';
import 'package:doctor/doctor/features/auth/screens/reset_password_screen.dart';
import 'package:doctor/doctor/features/auth/screens/splash_screen.dart';
import 'package:doctor/doctor/features/dashboard/bindings/doc_dashboard_binding.dart';
import 'package:doctor/doctor/features/dashboard/screens/doc_dashboard_screen.dart';
import 'package:doctor/doctor/features/emergency/bindings/doc_sos_binding.dart';
import 'package:doctor/doctor/features/emergency/bindings/doc_sos_detail_binding.dart';
import 'package:doctor/doctor/features/emergency/screens/doc_sos_detail_screen.dart';
import 'package:doctor/doctor/features/emergency/screens/doc_sos_screen.dart';
import 'package:doctor/doctor/features/notifications/bindings/doc_notification_binding.dart';
import 'package:doctor/doctor/features/notifications/screens/doc_notification_screen.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_blood_pressure_history_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_blood_sugar_history_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_create_diet_plan_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_create_medicine_reminder_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_diet_plans_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_edit_diet_plan_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_edit_medicine_reminder_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_kick_count_history_binding.dart';
// ============ MEDICINE REMINDER IMPORTS ============
import 'package:doctor/doctor/features/patient/bindings/doc_medicine_reminders_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_patient_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_patient_detail_binding.dart';
import 'package:doctor/doctor/features/patient/bindings/doc_send_message_binding.dart';
import 'package:doctor/doctor/features/patient/screens/doc_blood_pressure_history_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_blood_sugar_history_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_create_edit_diet_plan_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_create_edit_medicine_reminder_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_diet_plans_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_kick_count_history_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_medicine_reminders_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_patient_detail_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_patient_management_screen.dart';
import 'package:doctor/doctor/features/patient/screens/doc_send_message_screen.dart';
import 'package:doctor/doctor/features/profile/bindings/doc_add_payment_method_binding.dart';
import 'package:doctor/doctor/features/profile/bindings/doc_edit_profile_binding.dart';
import 'package:doctor/doctor/features/profile/bindings/doc_profile_binding.dart';
import 'package:doctor/doctor/features/profile/screens/doc_add_payment_method_screen.dart';
import 'package:doctor/doctor/features/profile/screens/doc_edit_profile_screen.dart';
import 'package:doctor/doctor/features/profile/screens/doc_profile_screen.dart';
import 'package:doctor/doctor/features/settings/screens/doc_payment_method_screen.dart';
import 'package:doctor/doctor/features/settings/screens/doc_settings_screen.dart';
// ===========================================================

// ============ PATIENT AI ASSISTANT FEATURE IMPORTS ============
import 'package:doctor/patient/features/ai_assistant/bindings/ai_assistant_binding.dart';
import 'package:doctor/patient/features/ai_assistant/screens/ai_assistant_screen.dart';
import 'package:doctor/patient/features/appointments/bindings/appointment_binding.dart';
import 'package:doctor/patient/features/appointments/bindings/book_appointment_binding.dart';
import 'package:doctor/patient/features/appointments/bindings/patient_appointment_detail_binding.dart';
import 'package:doctor/patient/features/appointments/bindings/reschedule_appointment_binding.dart';
import 'package:doctor/patient/features/appointments/screens/appointment_detail_screen.dart';
import 'package:doctor/patient/features/appointments/screens/appointments_screen.dart';
import 'package:doctor/patient/features/appointments/screens/book_appointment_screen.dart';
import 'package:doctor/patient/features/appointments/screens/reschedule_appointment_screen.dart';
// ===================================================

// ============ PATIENT DASHBOARD FEATURE IMPORTS ============
import 'package:doctor/patient/features/dashboard/bindings/patient_dashboard_binding.dart';
import 'package:doctor/patient/features/dashboard/screens/patient_dashboard_screen.dart';
import 'package:doctor/patient/features/diet_plans/bindings/diet_plan_binding.dart';
import 'package:doctor/patient/features/diet_plans/bindings/diet_plan_list_binding.dart';
import 'package:doctor/patient/features/diet_plans/screens/diet_plan_detail_screen.dart';
import 'package:doctor/patient/features/diet_plans/screens/diet_plans_screen.dart';
// ===========================================================

// ============ PATIENT DOCTORS FEATURE IMPORTS ============
import 'package:doctor/patient/features/doctors/bindings/doctor_binding.dart';
import 'package:doctor/patient/features/doctors/bindings/doctor_detail_binding.dart';
import 'package:doctor/patient/features/doctors/screens/doctor_detail_screen.dart';
import 'package:doctor/patient/features/doctors/screens/find_doctors_screen.dart';
import 'package:doctor/patient/features/emergency/bindings/emergency_binding.dart';
import 'package:doctor/patient/features/emergency/bindings/generate_sos_binding.dart';
import 'package:doctor/patient/features/emergency/screens/emergency_screen.dart';
import 'package:doctor/patient/features/emergency/screens/generate_sos_screen.dart';
// ===========================================================

// ============ PATIENT EXERCISE VIDEOS FEATURE IMPORTS ============
import 'package:doctor/patient/features/exercise_videos/bindings/exercise_video_binding.dart';
import 'package:doctor/patient/features/exercise_videos/screens/exercise_videos_screen.dart';
import 'package:doctor/patient/features/kick_counter/bindings/kick_counter_binding.dart';
import 'package:doctor/patient/features/kick_counter/bindings/kick_history_binding.dart';
import 'package:doctor/patient/features/kick_counter/screens/kick_counter_history_screen.dart';
import 'package:doctor/patient/features/kick_counter/screens/kick_counter_screen.dart';
import 'package:doctor/patient/features/medicine_reminders/bindings/add_medicine_reminder_binding.dart';
import 'package:doctor/patient/features/medicine_reminders/bindings/intake_log_binding.dart';
// =====================================================

// ============ PATIENT MEDICINE REMINDERS FEATURE IMPORTS ============
import 'package:doctor/patient/features/medicine_reminders/bindings/medicine_reminder_binding.dart';
import 'package:doctor/patient/features/medicine_reminders/bindings/medicine_reminder_detail_binding.dart';
import 'package:doctor/patient/features/medicine_reminders/screens/add_medicine_reminder_screen.dart';
import 'package:doctor/patient/features/medicine_reminders/screens/intake_log_screen.dart';
import 'package:doctor/patient/features/medicine_reminders/screens/medicine_reminder_detail_screen.dart';
import 'package:doctor/patient/features/medicine_reminders/screens/medicine_reminders_screen.dart';
import 'package:doctor/patient/features/settings/bindings/patient_change_password_binding.dart';
import 'package:doctor/patient/features/settings/bindings/patient_edit_profile_binding.dart';
// ===========================================================

// ============ PATIENT SETTINGS FEATURE IMPORTS ============
import 'package:doctor/patient/features/settings/bindings/patient_settings_binding.dart';
import 'package:doctor/patient/features/settings/screens/patient_change_password_screen.dart';
import 'package:doctor/patient/features/settings/screens/patient_edit_profile_screen.dart';
import 'package:doctor/patient/features/settings/screens/patient_settings_screen.dart';
// ===========================================================

// ============ PATIENT SURGICAL PROCEDURES FEATURE IMPORTS ============
import 'package:doctor/patient/features/surgical_procedures/bindnigs/surgical_procedure_binding.dart';
import 'package:doctor/patient/features/surgical_procedures/screens/surgical_procedures_screen.dart';
import 'package:doctor/patient/features/symptoms/bindings/symptoms_binding.dart';
import 'package:doctor/patient/features/symptoms/screens/symptoms_screen.dart';
import 'package:doctor/patient/features/vitals/bindings/vitals_bindings.dart';
import 'package:doctor/patient/features/vitals/screens/vitals_screen.dart';
import 'package:doctor/patient/features/water_intake/bindings/water_intake_binding.dart';
import 'package:doctor/patient/features/water_intake/bindings/water_intake_history_binding.dart';
import 'package:doctor/patient/features/water_intake/screens/water_intake_history_screen.dart';
import 'package:doctor/patient/features/water_intake/screens/water_intake_screen.dart';
// ======================================================================

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
    //doctor dashboard
    GetPage(
      name: AppRoutes.docdashboard,
      page: () => DoctorDashboardScreen(),
      binding: DoctorDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.docpatients,
      page: () => DoctorPatientManagementScreen(),
      binding: DoctorPatientBinding(),
    ),
    GetPage(
      name: AppRoutes.docpatientDetail,
      page: () => DoctorPatientDetailScreen(),
      binding: DoctorPatientDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.docappointments,
      page: () => const DoctorAppointmentScreen(),
      binding: DoctorAppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.docdietPlans,
      page: () => DoctorDietPlansScreen(),
      binding: DoctorDietPlansBinding(),
    ),
    GetPage(
      name: AppRoutes.doccreateDietPlan,
      page: () => const DoctorCreateEditDietPlanScreen(),
      binding: DoctorCreateDietPlanBinding(),
    ),
    GetPage(
      name: AppRoutes.doceditDietPlan,
      page: () => DoctorCreateEditDietPlanScreen(isEditing: true),
      binding: DoctorEditDietPlanBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.passwordResetSuccess,
      page: () => const PasswordResetSuccessScreen(),
    ),
    GetPage(
      name: AppRoutes.patientRegister,
      page: () => const PatientRegisterScreen(),
      binding: PatientRegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.docprofile,
      page: () => const DoctorProfileScreen(),
      binding: DoctorProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.docsettings,
      page: () => const DoctorSettingsScreen(),
      binding: DoctorProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.docappointmentDetail,
      page: () => const DoctorAppointmentDetailsScreen(),
      binding: DoctorAppointmentDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.doceditProfile,
      page: () => const DoctorEditProfileScreen(),
      binding: DoctorEditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.docpaymentMethods,
      page: () => const PaymentMethodsScreen(),
      binding: DoctorProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.docmedicineReminders,
      page: () => const DoctorMedicineRemindersScreen(),
      binding: DoctorMedicineRemindersBinding(),
    ),
    GetPage(
      name: AppRoutes.doccreateMedicineReminder,
      page: () => const DoctorCreateEditMedicineReminderScreen(),
      binding: DoctorCreateMedicineReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.doceditMedicineReminder,
      page: () => const DoctorCreateEditMedicineReminderScreen(isEditing: true),
      binding: DoctorEditMedicineReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.docsendMessage,
      page: () => const DoctorSendMessageScreen(),
      binding: DoctorSendMessageBinding(),
    ),

    GetPage(
      name: AppRoutes.docnotifications,
      page: () => const DoctorNotificationScreen(),
      binding: DoctorNotificationBinding(),
    ), // ==================================================
    GetPage(
      name: AppRoutes.docaddPaymentMethod,
      page: () => const DoctorAddPaymentMethodScreen(),
      binding: DoctorAddPaymentMethodBinding(),
    ),
    GetPage(
      name: AppRoutes.docsos,
      page: () => const DoctorSosScreen(),
      binding: DoctorSosBinding(),
    ),
    GetPage(
      name: AppRoutes.docsosDetail,
      page: () => const DoctorSosDetailScreen(),
      binding: DoctorSosDetailBinding(),
    ),

    // ============ HEALTH HISTORY ROUTES ============
    GetPage(
      name: AppRoutes.docbloodPressureHistory,
      page: () => const DoctorBloodPressureHistoryScreen(),
      binding: DoctorBloodPressureHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.docbloodSugarHistory,
      page: () => const DoctorBloodSugarHistoryScreen(),
      binding: DoctorBloodSugarHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.dockickCountHistory,
      page: () => const DoctorKickCountHistoryScreen(),
      binding: DoctorKickCountHistoryBinding(),
    ),
    // ===============================================

    // ============ PATIENT DASHBOARD ROUTES ============
    GetPage(
      name: AppRoutes.patientDashboard,
      page: () => const PatientDashboardScreen(),
      binding: PatientDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.patientSymptoms,
      page: () => const SymptomsScreen(),
      binding: SymptomsBinding(),
    ),
    GetPage(
      name: AppRoutes.patientWaterIntake,
      page: () => const WaterIntakeScreen(),
      binding: WaterIntakeBinding(),
    ),
    GetPage(
      name: AppRoutes.patientWaterIntakeHistory,
      page: () => const WaterIntakeHistoryScreen(),
      binding: WaterIntakeHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.patientKickCount,
      page: () => const KickCounterScreen(),
      binding: KickCounterBinding(),
    ),
    GetPage(
      name: AppRoutes.patientKickCountHistory,
      page: () => const KickHistoryScreen(),
      binding: KickHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.patientVitals,
      page: () => const VitalsScreen(),
      binding: VitalsBinding(),
    ),
    GetPage(
      name: AppRoutes.patientEmergency,
      page: () => const EmergencyScreen(),
      binding: EmergencyBinding(),
    ),
    GetPage(
      name: AppRoutes.generateSos,
      page: () => const GenerateSosScreen(),
      binding: GenerateSosBinding(),
    ),
    GetPage(
      name: AppRoutes.patientDietPlans,
      page: () => const DietPlansScreen(),
      binding: DietPlanListBinding(),
    ),
    GetPage(
      name: AppRoutes.patientDietPlanDetail,
      page: () => const DietPlanDetailScreen(),
      binding: DietPlanBinding(),
    ),
    GetPage(
      name: AppRoutes.patientAppointmentDetail,
      page: () => const AppointmentDetailScreen(),
      binding: AppointmentDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.patientAppointments,
      page: () => const AppointmentsScreen(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.bookAppointment,
      page: () => const BookAppointmentScreen(),
      binding: BookAppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.rescheduleAppointment,
      page: () => const RescheduleAppointmentScreen(),
      binding: RescheduleAppointmentBinding(),
    ),
    // ==================================================

    // ============ PATIENT DOCTORS ROUTES ============
    GetPage(
      name: AppRoutes.findDoctors,
      page: () => const FindDoctorsScreen(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorDetail,
      page: () => const DoctorDetailScreen(),
      binding: DoctorDetailBinding(),
    ),
    // ===============================================

    // ============ PATIENT AI ASSISTANT ROUTES ============
    GetPage(
      name: AppRoutes.patientAIAssistant,
      page: () => const AIAssistantScreen(),
      binding: AIAssistantBinding(),
    ),
    // ===============================================

    // ============ PATIENT SURGICAL PROCEDURES ROUTES ============
    GetPage(
      name: AppRoutes.patientSurgicalProcedures,
      page: () => const SurgicalProceduresScreen(),
      binding: SurgicalProcedureBinding(),
    ),
    // ===============================================

    // ============ PATIENT EXERCISE VIDEOS ROUTES ============
    GetPage(
      name: AppRoutes.patientExerciseVideos,
      page: () => const ExerciseVideosScreen(),
      binding: ExerciseVideoBinding(),
    ),
    // =========================================================

    // ============ PATIENT SETTINGS ROUTES ============
    GetPage(
      name: AppRoutes.patientSettings,
      page: () => const PatientSettingsScreen(),
      binding: PatientSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.patientEditProfile,
      page: () => const PatientEditProfileScreen(),
      binding: PatientEditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.patientChangePassword,
      page: () => const PatientChangePasswordScreen(),
      binding: PatientChangePasswordBinding(),
    ),
    // =====================================================

    // ============ PATIENT MEDICINE REMINDERS ROUTES ============
    GetPage(
      name: AppRoutes.medicineReminders,
      page: () => const MedicineRemindersScreen(),
      binding: MedicineReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.addMedicineReminder,
      page: () => const AddMedicineReminderScreen(),
      binding: AddMedicineReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.editMedicineReminder,
      page: () => const AddMedicineReminderScreen(),
      binding: AddMedicineReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.medicineIntakeLogs,
      page: () => const IntakeLogScreen(),
      binding: IntakeLogBinding(),
    ),
    GetPage(
      name: AppRoutes.medicineReminderDetail,
      page: () => const MedicineReminderDetailScreen(),
      binding: MedicineReminderDetailBinding(),
    ),
    // ==========================================================
  ];

  static List<GetPage> get pages => _pages;
}
