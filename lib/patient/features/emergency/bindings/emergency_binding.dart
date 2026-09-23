import 'package:doctor/patient/features/emergency/controllers/emergency_controller.dart';
import 'package:doctor/patient/features/emergency/repositories/emergency_repository.dart';
import 'package:get/get.dart';

class EmergencyBinding extends Bindings {
  @override
  void dependencies() {
    // Already registered globally in InitialBinding — just ensure findable
    if (!Get.isRegistered<EmergencyRepository>()) {
      Get.put<EmergencyRepository>(EmergencyRepository(), permanent: true);
    }
    if (!Get.isRegistered<EmergencyController>()) {
      Get.put<EmergencyController>(EmergencyController(), permanent: true);
    }
  }
}
