// lib/patient/features/diet_plans/bindings/diet_plan_binding.dart

import 'package:doctor/patient/features/diet_plans/controllers/diet_plan_controller.dart';
import 'package:doctor/patient/features/diet_plans/repositories/diet_plan_repository.dart';
import 'package:get/get.dart';

class DietPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DietPlanRepository>(() => DietPlanRepository());
    Get.lazyPut<DietPlanController>(() => DietPlanController());
  }
}
