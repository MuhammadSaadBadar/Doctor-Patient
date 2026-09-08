import 'package:get/get.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_profile_controller.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_profile_repository.dart';

class DoctorProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorProfileRepository>()) {
      Get.lazyPut<DoctorProfileRepository>(() => DoctorProfileRepository());
    }
    Get.put<DoctorProfileController>(
      DoctorProfileController(),
      permanent: true,
    );
  }
}
