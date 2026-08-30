// lib/features/notifications/providers/notification_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/notifications/controllers/doc_notification_controller.dart';

class DoctorNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorNotificationController());
  }
}
