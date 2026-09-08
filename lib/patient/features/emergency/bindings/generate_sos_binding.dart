import 'package:doctor/patient/features/emergency/controllers/generate_sos_controller.dart';
import 'package:doctor/patient/features/emergency/repositories/emergency_repository.dart';
import 'package:get/get.dart';

class GenerateSosBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EmergencyRepository>()) {
      Get.put<EmergencyRepository>(EmergencyRepository());
    }
    Get.lazyPut<GenerateSosController>(() => GenerateSosController());
  }
}
