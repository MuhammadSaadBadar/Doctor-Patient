import 'package:get/get.dart';
import 'package:doctor/doctor/features/appointments/controllers/doc_appointment_controller.dart';

class DoctorAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorAppointmentController());
  }
}
