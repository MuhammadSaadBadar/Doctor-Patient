// lib/features/notifications/providers/notification_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/notifications/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationController());
  }
}
