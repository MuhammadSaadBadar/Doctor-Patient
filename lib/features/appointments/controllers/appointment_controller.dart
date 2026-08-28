import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/features/appointments/repositories/appointment_repository.dart';
import 'package:doctor/features/appointments/models/appointment_schedule.dart';

enum AppointmentTab { upcoming, completed }

class AppointmentController extends GetxController {
  final AppointmentRepository _repository = AppointmentRepository();

  final currentTab = AppointmentTab.upcoming.obs;
  
  // State management
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Appointment lists
  final upcomingAppointments = <AppointmentSchedule>[].obs;
  final completedAppointments = <AppointmentSchedule>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Fetch all appointments (since the backend doesn't support payment status filtering)
      final allAppointments = await _repository.getAppointments(
        page: 1,
        pageSize: 100, // Fetch a larger page for client-side filtering
      );

      // Filter upcoming appointments: ONLY confirmed appointment status AND confirmed payment status
      upcomingAppointments.value = allAppointments.where((a) => 
        a.status == AppointmentStatus.confirmed && 
        a.payment?.status == AppointmentPaymentStatus.confirmed
      ).toList();

      // Filter completed appointments
      completedAppointments.value = allAppointments.where((a) => 
        a.status == AppointmentStatus.completed
      ).toList();
      
      debugPrint('[APPOINTMENT] Loaded ${upcomingAppointments.length} upcoming (confirmed+paid), ${completedAppointments.length} completed');
    } catch (e) {
      debugPrint('[APPOINTMENT] Error loading appointments: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load appointments. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(AppointmentTab tab) {
    currentTab.value = tab;
  }

  Future<void> refreshAppointments() async {
    await _loadAppointments();
  }

  /// Get appointments for the currently selected tab
  List<AppointmentSchedule> get filteredAppointments {
    switch (currentTab.value) {
      case AppointmentTab.upcoming:
        return upcomingAppointments;
      case AppointmentTab.completed:
        return completedAppointments;
    }
  }

  /// Check if there are any appointments for the current tab
  bool get hasAppointments => filteredAppointments.isNotEmpty;

  // Helper getters for UI
  bool get isLoadingProp => isLoading.value;
  bool get hasErrorProp => hasError.value;
  String get errorMessageProp => errorMessage.value;

  @override
  void onClose() {
    super.onClose();
  }
}