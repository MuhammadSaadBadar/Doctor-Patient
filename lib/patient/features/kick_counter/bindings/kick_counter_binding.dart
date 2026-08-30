// lib/patient/features/kick_counter/bindings/kick_counter_binding.dart

import 'package:doctor/patient/features/kick_counter/controllers/kick_counter_controller.dart';
import 'package:doctor/patient/features/kick_counter/repositories/kick_counter_repository.dart';
import 'package:get/get.dart';

class KickCounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KickCounterRepository>(() => KickCounterRepository());
    Get.lazyPut<KickCounterController>(() => KickCounterController());
  }
}
