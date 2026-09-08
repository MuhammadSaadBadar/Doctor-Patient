import 'package:doctor/patient/features/diet_plans/controllers/diet_plan_list_controller.dart';
import 'package:doctor/patient/features/diet_plans/repositories/diet_plan_repository.dart';
import 'package:get/get.dart';

class DietPlanListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DietPlanRepository>(() => DietPlanRepository());
    Get.lazyPut<DietPlanListController>(() => DietPlanListController());
  }
}
