// lib/features/patient/providers/blood_pressure_history_binding.dart

import 'package:get/get.dart';

import 'package:doctor/doctor/features/patient/controllers/doc_blood_pressure_history_controller.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';

class DoctorBloodPressureHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorBloodPressureHistoryController());
    Get.lazyPut<DoctorPatientRepository>(() => DoctorPatientRepository());
  }
}
