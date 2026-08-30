// lib/patient/features/diet_plan/bindings/diet_plan_detail_binding.dart

import 'package:doctor/patient/features/diet_plan/controllers/diet_plan_detail_controller.dart';
import 'package:get/get.dart';

class DietPlanDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DietPlanDetailController(planId: Get.arguments['id'], initialPlan: Get.arguments['plan']));
  }
}