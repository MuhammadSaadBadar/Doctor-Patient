import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_patient_detail_controller.dart';

class DoctorPatientDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorPatientDetailController());
  }
}
