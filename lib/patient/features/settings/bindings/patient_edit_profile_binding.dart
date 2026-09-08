// lib/patient/features/settings/bindings/patient_edit_profile_binding.dart

import 'package:doctor/patient/features/settings/controllers/patient_settings_controller.dart';
import 'package:doctor/patient/features/settings/repositories/patient_settings_repository.dart';
import 'package:get/get.dart';

class PatientEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientSettingsRepository>(
      () => PatientSettingsRepository(),
    );
    Get.lazyPut<PatientSettingsController>(
      () => PatientSettingsController(),
    );
  }
}