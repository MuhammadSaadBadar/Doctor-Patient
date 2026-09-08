// lib/patient/features/medicine_reminders/bindings/intake_log_binding.dart

import 'package:doctor/patient/features/medicine_reminders/controllers/intake_log_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart';
import 'package:get/get.dart';

class IntakeLogBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MedicineReminderRepository>()) {
      Get.put<MedicineReminderRepository>(
        MedicineReminderRepository(),
        permanent: true,
      );
    }
    Get.put<IntakeLogController>(
      IntakeLogController(),
      permanent: true,
    );
  }
}
