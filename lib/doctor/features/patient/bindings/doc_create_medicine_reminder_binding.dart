// lib/features/patient/providers/create_medicine_reminder_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_create_edit_medicine_reminder_controller.dart';

class DoctorCreateMedicineReminderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorCreateEditMedicineReminderController());
  }
}
