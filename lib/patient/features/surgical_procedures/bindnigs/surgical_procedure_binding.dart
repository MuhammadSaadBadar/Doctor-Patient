// lib/patient/features/surgical_procedures/bindings/surgical_procedure_binding.dart

import 'package:doctor/patient/features/surgical_procedures/controllers/surgical_procedure_controller.dart';
import 'package:doctor/patient/features/surgical_procedures/repositories/surgical_procedure_repository.dart';
import 'package:get/get.dart';

class SurgicalProcedureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurgicalProcedureRepository>(
      () => SurgicalProcedureRepository(),
    );
    Get.lazyPut<SurgicalProcedureController>(
      () => SurgicalProcedureController(),
    );
  }
}
