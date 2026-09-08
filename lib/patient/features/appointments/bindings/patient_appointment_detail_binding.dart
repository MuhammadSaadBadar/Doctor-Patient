// lib/patient/features/appointments/bindings/appointment_detail_binding.dart

import 'package:doctor/patient/features/appointments/controllers/appointment_detail_controller.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:get/get.dart';

class AppointmentDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.lazyPut<AppointmentRepository>(() => AppointmentRepository());
    }
    if (!Get.isRegistered<DoctorRepository>()) {
      Get.lazyPut<DoctorRepository>(() => DoctorRepository());
    }
    final args = Get.arguments;
    if (args == null || args['appointmentId'] == null) {
      throw ArgumentError(
        'appointmentId is required for AppointmentDetailScreen',
      );
    }
    Get.lazyPut<AppointmentDetailController>(
      () => AppointmentDetailController(
        appointmentId: args['appointmentId'] as int,
      ),
    );
  }
}
