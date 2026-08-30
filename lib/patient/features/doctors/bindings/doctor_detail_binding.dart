// lib/patient/features/doctors/bindings/doctor_detail_binding.dart

import 'package:doctor/patient/features/doctors/controllers/doctor_detail_controller.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:get/get.dart';

class DoctorDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorRepository>()) {
      Get.lazyPut<DoctorRepository>(() => DoctorRepository());
    }
    Get.lazyPut<DoctorDetailController>(() => DoctorDetailController());
  }
}
