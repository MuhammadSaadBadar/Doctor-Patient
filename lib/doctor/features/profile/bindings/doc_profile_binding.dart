import 'package:get/get.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_profile_controller.dart';

class DoctorProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorProfileController>(
      DoctorProfileController(),
      permanent: true,
    );
  }
}
