import 'package:get/get.dart';
import 'package:doctor/features/patient/controllers/diet_plans_controller.dart';

class DietPlansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DietPlansController());
  }
}
