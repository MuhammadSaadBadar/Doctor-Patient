// lib/patient/features/ai_assistant/bindings/ai_assistant_binding.dart

import 'package:doctor/patient/features/ai_assistant/controllers/ai_assistant_controller.dart';
import 'package:doctor/patient/features/ai_assistant/repositories/ai_assistant_repository.dart';
import 'package:get/get.dart';

class AIAssistantBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AIAssistantRepository>()) {
      Get.lazyPut<AIAssistantRepository>(() => AIAssistantRepository());
    }
    Get.lazyPut<AIAssistantController>(() => AIAssistantController());
  }
}
