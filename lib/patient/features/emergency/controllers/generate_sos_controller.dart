import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/emergency/repositories/emergency_repository.dart';
import 'package:doctor/patient/features/emergency/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class GenerateSosController extends GetxController {
  final EmergencyRepository _repository = Get.find<EmergencyRepository>();
  final LocationService _locationService = LocationService();
  final notesController = TextEditingController();
  final isSubmitting = false.obs;
  final isLoadingLocation = false.obs;
  final locationMessage = ''.obs;
  final position = Rxn<Position>();

  Future<void> captureLocation() async {
    isLoadingLocation.value = true;
    locationMessage.value = '';
    try {
      position.value = await _locationService.getCurrentPosition();
      if (position.value == null) {
        locationMessage.value = TranslationKeys.sosLocationUnavailable.tr;
      } else {
        locationMessage.value = TranslationKeys.sosCurrentLocationIncluded.tr;
      }
    } catch (_) {
        locationMessage.value = TranslationKeys.sosLocationUnavailable.tr;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      final created = await _repository.createSos(
        latitude: position.value?.latitude,
        longitude: position.value?.longitude,
        notes: notesController.text,
      );
      if (created == null) throw Exception(TranslationKeys.sosUnableToSend.tr);
      Get.back(result: true);
      Get.snackbar(TranslationKeys.sosSent.tr, TranslationKeys.sosSentDesc.tr);
    } catch (e) {
      Get.snackbar(
        TranslationKeys.sosUnableToSend.tr,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
