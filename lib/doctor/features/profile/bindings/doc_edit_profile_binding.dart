// lib/features/profile/providers/edit_profile_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_edit_profile_controller.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_edit_profile_repository.dart';

class DoctorEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorEditProfileRepository>()) {
      Get.lazyPut<DoctorEditProfileRepository>(
        () => DoctorEditProfileRepository(),
      );
    }
    Get.lazyPut(() => DoctorEditProfileController());
  }
}
