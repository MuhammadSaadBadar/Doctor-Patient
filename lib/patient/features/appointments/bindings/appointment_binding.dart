// lib/patient/features/appointments/bindings/appointment_binding.dart

import 'package:doctor/patient/features/appointments/controllers/appointment_controller.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:get/get.dart';

class AppointmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.lazyPut<AppointmentRepository>(() => AppointmentRepository());
    }
    final args = Get.arguments;
    final highlightId = args is Map ? args['highlightAppointmentId'] as int? : null;
    final autoUnpaid = args is Map ? (args['initialFilter'] == 'unpaid') : false;
    Get.lazyPut<AppointmentController>(
      () => AppointmentController(
        highlightAppointmentId: highlightId,
        autoSelectUnpaid: autoUnpaid,
      ),
    );
  }
}