// lib/features/patient/providers/send_message_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_send_message_controller.dart';

class DoctorSendMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorSendMessageController());
  }
}
