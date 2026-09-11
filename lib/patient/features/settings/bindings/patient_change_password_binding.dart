import 'package:doctor/patient/features/settings/controllers/patient_settings_controller.dart';
import 'package:get/get.dart';

class PatientChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientSettingsController>(() => PatientSettingsController(), fenix: true);
  }
}
