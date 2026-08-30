// lib/patient/features/dashboard/bindings/patient_dashboard_binding.dart

import 'package:doctor/patient/features/dashboard/controllers/patient_dashboard_controller.dart';
import 'package:doctor/patient/features/dashboard/repositories/patient_dashboard_repository.dart';
import 'package:get/get.dart';

class PatientDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientDashboardRepository>(
      () => PatientDashboardRepository(),
    );
    Get.lazyPut<PatientDashboardController>(
      () => PatientDashboardController(),
    );
  }
}