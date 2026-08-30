import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/controllers/doc_kick_count_history_controller.dart';

class DoctorKickCountHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorKickCountHistoryController());
  }
}
