// lib/features/patient/providers/blood_sugar_history_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_blood_sugar_history_controller.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';

class DoctorBloodSugarHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorBloodSugarHistoryController());
    Get.lazyPut<DoctorPatientRepository>(() => DoctorPatientRepository());
  }
}
