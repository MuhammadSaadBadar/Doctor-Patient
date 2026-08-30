// lib/patient/features/kick_counter/bindings/kick_history_binding.dart

import 'package:doctor/patient/features/kick_counter/controllers/kick_history_controller.dart';
import 'package:doctor/patient/features/kick_counter/repositories/kick_counter_repository.dart';
import 'package:get/get.dart';

class KickHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KickCounterRepository>(() => KickCounterRepository());
    Get.lazyPut<KickHistoryController>(() => KickHistoryController());
  }
}
