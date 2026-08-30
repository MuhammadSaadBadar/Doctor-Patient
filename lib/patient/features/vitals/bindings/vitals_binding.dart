// lib/patient/features/vitals/bindings/vitals_binding.dart

import 'package:doctor/patient/features/vitals/controllers/vitals_controller.dart';
import 'package:get/get.dart';

class VitalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VitalsController());
  }
}