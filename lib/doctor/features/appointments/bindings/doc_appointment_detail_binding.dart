import 'package:get/get.dart';
import 'package:doctor/doctor/features/appointments/controllers/doc_appointment_detail_controller.dart';

class DoctorAppointmentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorAppointmentDetailController());
  }
}
