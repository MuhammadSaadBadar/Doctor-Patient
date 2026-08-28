// lib/features/emergency/providers/sos_detail_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/emergency/controllers/sos_detail_controller.dart';

class SosDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SosDetailController());
  }
}
