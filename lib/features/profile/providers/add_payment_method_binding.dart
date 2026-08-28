// lib/features/profile/providers/add_payment_method_binding.dart

import 'package:get/get.dart';
import 'package:doctor/features/profile/controllers/add_payment_method_controller.dart';

class AddPaymentMethodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddPaymentMethodController());
  }
}
