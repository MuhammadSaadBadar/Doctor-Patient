import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/features/patient/models/diet_plan_form.dart';
import 'package:doctor/features/patient/repositories/patient_repository.dart';

class CreateEditDietPlanController extends GetxController {
  final PatientRepository _repository = PatientRepository();

  final formKey = GlobalKey<FormState>();
  final formData = Rxn<DietPlanFormData>();
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Meal type options from API
  final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  // Validation errors
  final patientIdError = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Determine if we are editing by checking route arguments
    final args = Get.arguments;
    final planId = args is Map ? args['planId'] as String? : null;
    final isEditing = args is Map && (args['isEditing'] as bool? ?? false);
    final argPatientId = args is Map ? args['patientId'] as int? : null;

    if (isEditing && planId != null) {
      _loadDietPlan(planId, argPatientId);
    } else {
      // New plan - get patient ID from arguments
      formData.value = DietPlanFormData(
        patientId: argPatientId,
      );
    }
  }

  Future<void> _loadDietPlan(String planId, [int? fallbackPatientId]) async {
    isLoading.value = true;
    try {
      final planData = await _repository.getDietPlan(planId);
      if (planData != null) {
        var loadedFormData = DietPlanFormData.fromJson(planData);
        // Fallback: if patientId still null, use fallback or extract from planData
        if (loadedFormData.patientId == null) {
          final extractedPatientId = planData['patient_id'] as int? ??
              (planData['patient'] as Map<String, dynamic>?)?['id'] as int? ??
              fallbackPatientId;
          loadedFormData = loadedFormData.copyWith(patientId: extractedPatientId);
        }
        formData.value = loadedFormData;
      } else {
        Get.snackbar(
          'Error',
          'Failed to load diet plan.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load diet plan. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      debugPrint('[DIET_PLAN] Error loading plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void savePlan() {
    // Clear previous errors
    patientIdError.value = '';

    // Validate that we have a patient ID BEFORE form validation
    final patientId = formData.value?.patientId;
    if (patientId == null) {
      patientIdError.value = 'Patient ID is required. Please select a patient.';
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState!.save();

      isSaving.value = true;

      // Save the diet plan
      final data = formData.value!;
      final isEditing = data.id.isNotEmpty;

      Future<Map<String, dynamic>?> saveFuture;
      if (isEditing) {
        // For updates, ensure patient_id is in the payload
        final payload = data.toJson();
        payload['patient_id'] = patientId; // Force include patient_id
        saveFuture = _repository.updateDietPlan(data.id, payload);
      } else {
        saveFuture = _repository.createDietPlan(data.toJson());
      }

      saveFuture
          .then((result) {
            isSaving.value = false;
            if (result != null) {
              Get.back(result: true);
              Get.snackbar(
                'Success',
                isEditing
                    ? 'Diet plan updated successfully!'
                    : 'Diet plan created successfully!',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar(
                'Error',
                isEditing
                    ? 'Failed to update diet plan.'
                    : 'Failed to create diet plan.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.error,
                colorText: AppColors.onError,
              );
            }
          })
          .catchError((e) {
            isSaving.value = false;
            Get.snackbar(
              'Error',
              'An error occurred. Please try again.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.error,
              colorText: AppColors.onError,
            );
            debugPrint('[DIET_PLAN] Error saving plan: $e');
          });
    }
  }

  // Meal management
  void addMeal() {
    final current = formData.value;
    if (current == null) return;

    // Default to first meal type
    final mealType = mealTypes.first;
    formData.value = current.copyWith(
      meals: [
        ...current.meals,
        DietPlanMeal(mealType: mealType, description: ''),
      ],
    );
  }

  void removeMeal(int index) {
    final current = formData.value;
    if (current == null || current.meals.length <= 1) return;

    final updatedMeals = List<DietPlanMeal>.from(current.meals);
    updatedMeals.removeAt(index);
    formData.value = current.copyWith(meals: updatedMeals);
  }

  void updateMeal(int index, String mealType, String description) {
    final current = formData.value;
    if (current == null) return;

    final updatedMeals = List<DietPlanMeal>.from(current.meals);
    updatedMeals[index] = DietPlanMeal(
      mealType: mealType,
      description: description,
    );
    formData.value = current.copyWith(meals: updatedMeals);
  }

  // Food avoidance management
  void addFoodToAvoid() {
    final current = formData.value;
    if (current == null) return;

    formData.value = current.copyWith(
      foodsToAvoid: [
        ...current.foodsToAvoid,
        DietPlanFoodAvoidance(foodName: '', reason: ''),
      ],
    );
  }

  void removeFoodToAvoid(int index) {
    final current = formData.value;
    if (current == null || current.foodsToAvoid.isEmpty) return;

    final updatedFoods = List<DietPlanFoodAvoidance>.from(current.foodsToAvoid);
    updatedFoods.removeAt(index);
    formData.value = current.copyWith(foodsToAvoid: updatedFoods);
  }

  void updateFoodToAvoid(int index, String foodName, String reason) {
    final current = formData.value;
    if (current == null) return;

    final updatedFoods = List<DietPlanFoodAvoidance>.from(current.foodsToAvoid);
    updatedFoods[index] = DietPlanFoodAvoidance(
      foodName: foodName,
      reason: reason,
    );
    formData.value = current.copyWith(foodsToAvoid: updatedFoods);
  }

  @override
  void onClose() {
    super.onClose();
  }
}