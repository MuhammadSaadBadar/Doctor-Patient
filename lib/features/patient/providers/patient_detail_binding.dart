import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/patient_detail_controller.dart';

class PatientDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientDetailController());
  }
}
