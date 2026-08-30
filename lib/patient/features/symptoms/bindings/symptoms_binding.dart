// lib/patient/features/symptoms/bindings/symptoms_binding.dart

import 'package:doctor/patient/features/symptoms/controllers/symptoms_controller.dart';
import 'package:get/get.dart';

class SymptomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SymptomsController());
  }
}