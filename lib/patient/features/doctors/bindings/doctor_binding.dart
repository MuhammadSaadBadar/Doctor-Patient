// lib/patient/features/doctors/bindings/doctor_binding.dart

import 'package:doctor/patient/features/doctors/controllers/doctor_controller.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:get/get.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorRepository>()) {
      Get.lazyPut<DoctorRepository>(() => DoctorRepository());
    }
    Get.lazyPut<DoctorController>(() => DoctorController());
  }
}
