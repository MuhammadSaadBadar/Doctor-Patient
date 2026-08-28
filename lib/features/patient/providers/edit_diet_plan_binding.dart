import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/create_diet_plan_controller.dart';

class EditDietPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateEditDietPlanController());
  }
}
