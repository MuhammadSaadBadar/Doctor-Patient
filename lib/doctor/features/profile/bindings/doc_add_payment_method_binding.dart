// lib/features/profile/providers/add_payment_method_binding.dart

import 'package:get/get.dart';
import 'package:doctor/doctor/features/profile/controllers/doc_add_payment_method_controller.dart';

class DoctorAddPaymentMethodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorAddPaymentMethodController());
  }
}
