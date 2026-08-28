import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/patient_management_controller.dart';

class PatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientManagementController(), fenix: true);
  }
}
