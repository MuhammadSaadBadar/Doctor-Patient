// lib/patient/features/appointments/bindings/reschedule_appointment_binding.dart

import 'package:doctor/patient/features/appointments/controllers/reschedule_appointment_controller.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:get/get.dart';

class RescheduleAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.lazyPut<AppointmentRepository>(() => AppointmentRepository());
    }
    final args = Get.arguments;
    if (args == null || args['appointmentId'] == null) {
      throw ArgumentError(
        'appointmentId is required for RescheduleAppointmentScreen',
      );
    }
    Get.lazyPut<RescheduleAppointmentController>(
      () => RescheduleAppointmentController(
        appointmentId: args['appointmentId'] as int,
      ),
    );
  }
}
