import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController is already registered permanently in InitialBinding.
    // Do not re-register here to avoid duplicate/disposed instances.
  }
}
