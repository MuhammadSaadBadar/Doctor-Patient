import 'package:get/get.dart';
import 'package:doctor/doctor/features/dashboard/controllers/doc_dashboard_controller.dart';

class DoctorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorDashboardController(), fenix: true);
  }
}
