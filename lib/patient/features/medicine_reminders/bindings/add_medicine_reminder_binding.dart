// lib/patient/features/medicine_reminders/bindings/add_medicine_reminder_binding.dart

import 'package:doctor/patient/features/medicine_reminders/controllers/add_medicine_reminder_controller.dart';
import 'package:get/get.dart';

class AddMedicineReminderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMedicineReminderController>(
      () => AddMedicineReminderController(),
    );
  }
}
