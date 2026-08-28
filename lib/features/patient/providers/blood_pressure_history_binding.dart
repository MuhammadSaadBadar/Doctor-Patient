// lib/features/patient/providers/blood_pressure_history_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/blood_pressure_history_controller.dart';
import 'package:doctor/features/patient/repositories/patient_repository.dart';

class BloodPressureHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BloodPressureHistoryController());
    Get.lazyPut<PatientRepository>(() => PatientRepository());
  }
}
