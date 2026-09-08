// lib/patient/features/symptoms/bindings/symptoms_binding.dart

import 'package:doctor/patient/features/symptoms/controllers/symptoms_controller.dart';
import 'package:doctor/patient/features/symptoms/repositories/symptoms_repository.dart';
import 'package:get/get.dart';

class SymptomsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SymptomsRepository>()) {
      Get.lazyPut(() => SymptomsRepository());
    }
    Get.lazyPut(() => SymptomsController());
  }
}