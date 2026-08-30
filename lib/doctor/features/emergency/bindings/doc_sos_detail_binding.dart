// lib/features/emergency/providers/sos_detail_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/emergency/controllers/doc_sos_detail_controller.dart';

class DoctorSosDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorSosDetailController());
  }
}
