import 'package:doctor/patient/features/emergency/controllers/emergency_controller.dart';
import 'package:doctor/patient/features/emergency/repositories/emergency_repository.dart';
import 'package:get/get.dart';

class EmergencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmergencyRepository>(() => EmergencyRepository());
    Get.lazyPut<EmergencyController>(() => EmergencyController());
  }
}
