// lib/patient/features/water_intake/bindings/water_intake_history_binding.dart

import 'package:doctor/patient/features/water_intake/controllers/water_intake_history_controller.dart';
import 'package:doctor/patient/features/water_intake/repositories/water_intake_repository.dart';
import 'package:get/get.dart';

class WaterIntakeHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WaterIntakeRepository>(() => WaterIntakeRepository());
    Get.lazyPut<WaterIntakeHistoryController>(() => WaterIntakeHistoryController());
  }
}