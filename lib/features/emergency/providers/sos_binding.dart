// lib/features/emergency/providers/sos_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/emergency/controllers/sos_controller.dart';

class SosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SosController());
  }
}
