import 'package:doctor/doctor/features/auth/controllers/patient_register_controller.dart';
import 'package:get/get.dart';

class PatientRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientRegisterController>(() => PatientRegisterController());
  }
}
