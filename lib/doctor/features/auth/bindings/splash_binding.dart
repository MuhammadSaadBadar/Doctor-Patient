import 'package:get/get.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
