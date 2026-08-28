import 'package:get/get.dart';
import 'package:doctor/features/appointments/controllers/appointment_detail_controller.dart';

class AppointmentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentDetailController());
  }
}
