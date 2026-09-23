import 'package:get/get.dart';
import 'package:doctor/doctor/features/dashboard/controllers/doc_dashboard_controller.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_profile_repository.dart';

class DoctorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorProfileRepository(), fenix: true);
    Get.lazyPut(() => DoctorDashboardController(), fenix: true);
  }
}
