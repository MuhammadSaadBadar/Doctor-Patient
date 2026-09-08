// lib/patient/features/surgical_procedures/controllers/add_procedure_controller.dart

import 'package:doctor/patient/features/surgical_procedures/models/procedure_request.dart';
import 'package:doctor/patient/features/surgical_procedures/models/surgical_procedure.dart';
import 'package:doctor/patient/features/surgical_procedures/repositories/surgical_procedure_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProcedureController extends GetxController {
  final SurgicalProcedureRepository _repository = Get.find<SurgicalProcedureRepository>();

  // State
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Form Controllers
  final procedureNameController = TextEditingController();
  final hospitalNameController = TextEditingController();
  final notesController = TextEditingController();

  // Form State
  final selectedDate = Rx<DateTime?>(DateTime.now());
  final isEditing = false.obs;
  final editingId = 0.obs;

  // Form Validation
  final procedureNameError = ''.obs;
  final dateError = ''.obs;

  // Computed
  bool get isValid {
    final nameValid = procedureNameController.text.trim().isNotEmpty;
    final dateValid = selectedDate.value != null;
    return nameValid && dateValid;
  }

  int get notesLength => notesController.text.length;
  int get notesMaxLength => 500;

  @override
  void onInit() {
    super.onInit();
    // Check if editing
    final args = Get.arguments;
    if (args is Map && args.containsKey('procedure')) {
      final procedure = args['procedure'] as SurgicalProcedure;
      _loadForEditing(procedure);
    }
  }

  @override
  void onClose() {
    procedureNameController.dispose();
    hospitalNameController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _loadForEditing(SurgicalProcedure procedure) {
    isEditing.value = true;
    editingId.value = procedure.id;
    procedureNameController.text = procedure.procedureName;
    selectedDate.value = procedure.procedureDate;
    hospitalNameController.text = procedure.hospitalName ?? '';
    notesController.text = procedure.notes ?? '';
  }

  void validateProcedureName() {
    final name = procedureNameController.text.trim();
    if (name.isEmpty) {
      procedureNameError.value = 'Please enter a procedure name';
    } else if (name.length < 2) {
      procedureNameError.value = 'Procedure name must be at least 2 characters';
    } else {
      procedureNameError.value = '';
    }
  }

  void validateDate() {
    if (selectedDate.value == null) {
      dateError.value = 'Please select a procedure date';
    } else if (selectedDate.value!.isAfter(DateTime.now())) {
      dateError.value = 'Procedure date cannot be in the future';
    } else {
      dateError.value = '';
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      selectedDate.value = date;
      validateDate();
    }
  }

  Future<void> submit() async {
    // Validate all fields
    validateProcedureName();
    validateDate();

    if (!isValid) return;

    isSubmitting.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final request = ProcedureRequest(
        procedureName: procedureNameController.text.trim(),
        procedureDate: selectedDate.value!,
        hospitalName: hospitalNameController.text.trim().isEmpty
            ? null
            : hospitalNameController.text.trim(),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      SurgicalProcedure? result;

      if (isEditing.value) {
        result = await _repository.updateProcedure(editingId.value, request);
      } else {
        result = await _repository.createProcedure(request);
      }

      if (result != null) {
        Get.back(result: result);
      } else {
        hasError.value = true;
        errorMessage.value = isEditing.value
            ? 'Failed to update procedure. Please try again.'
            : 'Failed to add procedure. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[ADD_PROCEDURE] Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void cancel() {
    Get.back(result: null);
  }

  String getTitle() {
    return isEditing.value
        ? 'Edit Surgical Procedure'
        : 'Add Surgical Procedure';
  }

  String getSubmitLabel() {
    return isEditing.value ? 'Update Procedure' : 'Save Procedure';
  }
}
