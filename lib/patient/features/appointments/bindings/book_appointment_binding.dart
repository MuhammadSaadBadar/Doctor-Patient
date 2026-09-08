// lib/patient/features/appointments/bindings/book_appointment_binding.dart

import 'package:doctor/patient/features/appointments/controllers/book_appointment_controller.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:get/get.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.lazyPut<AppointmentRepository>(() => AppointmentRepository());
    }
    if (!Get.isRegistered<DoctorRepository>()) {
      Get.lazyPut<DoctorRepository>(() => DoctorRepository());
    }
    final args = Get.arguments;
    if (args == null || args['doctorId'] == null) {
      throw ArgumentError('doctorId is required for BookAppointmentScreen');
    }
    Get.lazyPut<BookAppointmentController>(
      () => BookAppointmentController(doctorId: args['doctorId'] as int),
    );
  }
}
