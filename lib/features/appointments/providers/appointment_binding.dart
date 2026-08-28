import 'package:get/get.dart';
import 'package:doctor/features/appointments/controllers/appointment_controller.dart';

class AppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentController());
  }
}
