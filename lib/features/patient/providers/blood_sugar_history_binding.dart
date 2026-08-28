// lib/features/patient/providers/blood_sugar_history_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/blood_sugar_history_controller.dart';
import 'package:doctor/features/patient/repositories/patient_repository.dart';

class BloodSugarHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BloodSugarHistoryController());
    Get.lazyPut<PatientRepository>(() => PatientRepository());
  }
}