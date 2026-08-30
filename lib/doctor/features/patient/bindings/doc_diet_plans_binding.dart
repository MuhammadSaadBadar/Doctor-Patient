import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_diet_plans_controller.dart';

class DoctorDietPlansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorDietPlansController());
  }
}
