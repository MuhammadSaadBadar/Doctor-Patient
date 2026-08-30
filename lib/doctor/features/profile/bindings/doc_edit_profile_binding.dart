// lib/features/profile/providers/edit_profile_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_edit_profile_controller.dart';

class DoctorEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorEditProfileController());
  }
}
