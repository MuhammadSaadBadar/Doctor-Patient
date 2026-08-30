// lib/patient/features/appointment/bindings/appointment_detail_binding.dart

import 'package:doctor/patient/features/appointment/controllers/appointment_detail_controller.dart';
import 'package:get/get.dart';

class PatientAppointmentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => PatientAppointmentDetailController(
        appointmentId: Get.arguments['id'],
        initialAppointment: Get.arguments['appointment'],
      ),
    );
  }
}
