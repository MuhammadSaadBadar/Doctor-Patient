// lib/features/patient/providers/medicine_reminders_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_medicine_reminders_controller.dart';

class DoctorMedicineRemindersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorMedicineRemindersController());
  }
}
