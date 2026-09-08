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
        locationMessage.value =
            'Location unavailable. SOS can still be sent without it.';
      } else {
        locationMessage.value = 'Current location will be included.';
      }
    } catch (_) {
      locationMessage.value =
          'Location unavailable. SOS can still be sent without it.';
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
      if (created == null) throw Exception('SOS could not be created.');
      Get.back(result: true);
      Get.snackbar('SOS sent', 'Your emergency alert has been sent.');
    } catch (e) {
      Get.snackbar(
        'Unable to send SOS',
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
