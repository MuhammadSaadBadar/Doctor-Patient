// lib/features/emergency/providers/sos_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/emergency/controllers/doc_sos_controller.dart';

class DoctorSosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorSosController());
  }
}
