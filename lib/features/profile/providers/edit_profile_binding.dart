// lib/features/profile/providers/edit_profile_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/profile/controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
  }
}
