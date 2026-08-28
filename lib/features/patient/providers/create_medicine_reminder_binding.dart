// lib/features/patient/providers/create_medicine_reminder_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/create_edit_medicine_reminder_controller.dart';

class CreateMedicineReminderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateEditMedicineReminderController());
  }
}
