// lib/patient/features/medicine_reminders/bindings/medicine_reminder_detail_binding.dart

import 'package:doctor/patient/features/medicine_reminders/controllers/intake_log_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/controllers/medicine_reminder_detail_controller.dart';
import 'package:doctor/patient/features/medicine_reminders/repositories/medicine_reminder_repository.dart';
import 'package:get/get.dart';

class MedicineReminderDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MedicineReminderRepository>()) {
      Get.put<MedicineReminderRepository>(
        MedicineReminderRepository(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<IntakeLogController>()) {
      Get.put<IntakeLogController>(IntakeLogController(), permanent: true);
    }
    Get.lazyPut<MedicineReminderDetailController>(
      () => MedicineReminderDetailController(),
    );
  }
}
