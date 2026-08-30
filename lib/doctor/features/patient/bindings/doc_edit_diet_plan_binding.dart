import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_create_diet_plan_controller.dart';

class DoctorEditDietPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorCreateEditDietPlanController());
  }
}
