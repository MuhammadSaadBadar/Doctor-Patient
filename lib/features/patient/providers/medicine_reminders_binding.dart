// lib/features/patient/providers/medicine_reminders_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/medicine_reminders_controller.dart';

class MedicineRemindersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MedicineRemindersController());
  }
}
