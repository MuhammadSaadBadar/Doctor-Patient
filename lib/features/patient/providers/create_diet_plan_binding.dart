import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/create_diet_plan_controller.dart';

class CreateDietPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateEditDietPlanController());
  }
}
