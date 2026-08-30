import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_patient_management_controller.dart';

class DoctorPatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorPatientManagementController(), fenix: true);
  }
}
