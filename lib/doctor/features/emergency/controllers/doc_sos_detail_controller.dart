// lib/features/emergency/controllers/sos_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/doctor/features/emergency/models/doc_sos_event.dart';
import 'package:doctor/doctor/features/emergency/repositories/doc_sos_repository.dart';

class DoctorSosDetailController extends GetxController {
  final DoctorSosRepository _repository = DoctorSosRepository();

  final event = Rxn<SosEvent>();
  final isLoading = true.obs;
  final isResolving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  String get eventId => Get.arguments?['eventId'] as String? ?? '';

  @override
  void onInit() {
    super.onInit();
    if (eventId.isNotEmpty) {
      _loadSosEvent();
    } else {
      hasError.value = true;
      errorMessage.value = 'Event ID not found';
      isLoading.value = false;
    }
  }

  Future<void> _loadSosEvent() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final data = await _repository.getSosEvent(eventId);
      if (data != null) {
        event.value = data;
      } else {
        throw Exception('Failed to load SOS event');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[SOS_DETAIL] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshEvent() async {
    await _loadSosEvent();
  }

  Future<void> resolveEvent({required String status}) async {
    if (event.value == null) return;

    isResolving.value = true;

    try {
      final updated = await _repository.resolveSosEvent(
        id: event.value!.id,
        status: status,
      );

      if (updated != null) {
        event.value = updated;
        final isResolved = status == 'resolved';
        Get.snackbar(
          'Success',
          isResolved
              ? 'SOS alert marked as resolved'
              : 'SOS alert marked as false alarm',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isResolved
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          colorText: isResolved ? Colors.green[800] : Colors.orange[800],
        );
      } else {
        throw Exception('Failed to update SOS event');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    } finally {
      isResolving.value = false;
    }
  }

  void goBack() {
    Get.back(result: true);
  }
}
