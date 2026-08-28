// lib/features/patient/providers/send_message_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/send_message_controller.dart';

class SendMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SendMessageController());
  }
}
