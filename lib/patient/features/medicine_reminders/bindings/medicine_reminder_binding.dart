// lib/patient/features/medicine_reminders/bindings/medicine_reminder_binding.dart

import 'package:doctor/patient/features/medicine_reminders/controllers/intake_log_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart';
import 'package:get/get.dart';

class MedicineReminderBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MedicineReminderRepository>(
      MedicineReminderRepository(),
      permanent: true,
    );
    Get.put<IntakeLogController>(
      IntakeLogController(),
      permanent: true,
    );
    Get.lazyPut<MedicineReminderController>(() => MedicineReminderController());
  }
}
