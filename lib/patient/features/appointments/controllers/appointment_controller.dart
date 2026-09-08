import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/appointments/models/appointment.dart';
import 'package:doctor/patient/features/appointments/models/paginated_appointment_list.dart';
import 'package:doctor/patient/features/appointments/repositories/appointment_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Filter tabs enum (top-level for external access)
enum AppointmentFilter { all, pending, confirmed, unpaid }

class AppointmentController extends GetxController {
  AppointmentController({
    this.highlightAppointmentId,
    this.autoSelectUnpaid = false,
  });

  final AppointmentRepository _repository = Get.find<AppointmentRepository>();

  // State
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final allAppointments = <Appointment>[].obs;
  final filteredAppointments = <Appointment>[].obs;
  final paginatedData = Rx<PaginatedAppointmentList?>(null);

  // Filter
  final selectedFilter = AppointmentFilter.all.obs;

  // Post-booking hints
  final int? highlightAppointmentId;
  final bool autoSelectUnpaid;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final totalCount = 0.obs;

  // Computed getters
  bool get hasAppointments => filteredAppointments.isNotEmpty;
  bool get isEmpty => !hasAppointments && !isLoading.value;

  int get allCount => allAppointments.length;
  int get pendingCount => allAppointments.where((a) => a.isPending).length;
  int get confirmedCount => allAppointments.where((a) => a.isConfirmed).length;
  int get unpaidCount => allAppointments.where((a) => a.isUnpaid).length;

  @override
  void onInit() {
    super.onInit();
    if (autoSelectUnpaid) {
      selectedFilter.value = AppointmentFilter.unpaid;
    }
    loadAppointments(refresh: true);
  }

  Future<void> loadAppointments({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      allAppointments.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = allAppointments.isEmpty;
    isLoadingMore.value = allAppointments.isNotEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // API doesn't support status filtering for patients; do all filtering client-side
      final result = await _repository.getAppointments(
        page: currentPage.value,
        pageSize: 20,
        status: null,
      );

      if (result != null) {
        allAppointments.addAll(result.results);
        paginatedData.value = result;
        hasMoreData.value = result.hasNext;
        totalCount.value = result.count;
        currentPage.value++;

        debugPrint(
          '[APPOINTMENT] Loaded ${allAppointments.length} of ${result.count} appointments',
        );
        _applyFilter();
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load appointments. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[APPOINTMENT] Error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadAppointments(refresh: true);
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await loadAppointments();
  }

  void _applyFilter() {
    switch (selectedFilter.value) {
      case AppointmentFilter.all:
        filteredAppointments.value = List.from(allAppointments);
        break;
      case AppointmentFilter.pending:
        filteredAppointments.value = allAppointments
            .where((a) => a.isPending)
            .toList();
        break;
      case AppointmentFilter.confirmed:
        filteredAppointments.value = allAppointments
            .where((a) => a.isConfirmed)
            .toList();
        break;
      case AppointmentFilter.unpaid:
        filteredAppointments.value = allAppointments
            .where((a) => a.isUnpaid)
            .toList();
        break;
    }
  }

  void setFilter(AppointmentFilter filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void navigateToBookAppointment() {
    Get.toNamed(AppRoutes.bookAppointment);
  }

  void navigateToAppointmentDetail(int appointmentId) {
    Get.toNamed(
      AppRoutes.patientAppointmentDetail,
      arguments: {'appointmentId': appointmentId},
    );
  }

  String getFilterLabel(AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.all:
        return 'All';
      case AppointmentFilter.pending:
        return 'Pending';
      case AppointmentFilter.confirmed:
        return 'Confirmed';
      case AppointmentFilter.unpaid:
        return 'Unpaid';
    }
  }

  int getFilterCount(AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.all:
        return allCount;
      case AppointmentFilter.pending:
        return pendingCount;
      case AppointmentFilter.confirmed:
        return confirmedCount;
      case AppointmentFilter.unpaid:
        return unpaidCount;
    }
  }

  // Action methods
  void cancelAppointment(Appointment appointment) {
    _showCancelDialog(appointment);
  }

  void _showCancelDialog(Appointment appointment) {
    final colorScheme = Get.theme.colorScheme;
    final reasonController = TextEditingController();

    Get.defaultDialog(
      title: 'Cancel Appointment',
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure you want to cancel your appointment with ${appointment.doctorFullName} on ${appointment.formattedDate} at ${appointment.formattedTime}?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'e.g., scheduling conflict, feeling better',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      textCancel: 'Keep',
      textConfirm: 'Cancel',
      confirmTextColor: colorScheme.onPrimary,
      buttonColor: colorScheme.error,
      cancelTextColor: colorScheme.onSurface,
      onConfirm: () async {
        Get.back();
        final reason = reasonController.text.trim();
        final result = await _repository.cancelAppointment(
          appointment.id,
          reason: reason.isEmpty ? null : reason,
        );
        if (result != null) {
          // Update the appointment in the list
          final index = allAppointments.indexWhere(
            (a) => a.id == appointment.id,
          );
          if (index != -1) {
            allAppointments[index] = result;
            _applyFilter();
          }
          Get.snackbar(
            'Cancelled',
            'Appointment cancelled successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to cancel appointment. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void navigateToReschedule(Appointment appointment) {
    Get.toNamed(
      AppRoutes.rescheduleAppointment,
      arguments: {'appointmentId': appointment.id},
    )?.then((result) {
      if (result == true) {
        refreshData();
      }
    });
  }

  Future<void> markPaymentAsPaid(Appointment appointment) async {
    final result = await _repository.markPaymentAsPaid(appointment.id);
    if (result != null) {
      final index = allAppointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        allAppointments[index] = result;
        _applyFilter();
      }
      Get.snackbar(
        'Payment Marked',
        'Payment marked as paid. Awaiting admin verification.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to mark payment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void rateAppointment(Appointment appointment) {
    _showRatingDialog(appointment);
  }

  void _showRatingDialog(Appointment appointment) {
    final colorScheme = Get.theme.colorScheme;
    int selectedScore = 5;
    final commentController = TextEditingController();

    Get.defaultDialog(
      title: 'Rate Your Appointment',
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How was your appointment with ${appointment.doctorFullName}?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => selectedScore = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= selectedScore
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 36,
                        color: star <= selectedScore
                            ? Colors.amber
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              hintText: 'Share your experience...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      textCancel: 'Cancel',
      textConfirm: 'Submit Rating',
      confirmTextColor: Colors.white,
      buttonColor: Colors.amber.shade700,
      cancelTextColor: colorScheme.onSurface,
      onConfirm: () async {
        Get.back();
        final comment = commentController.text.trim();
        final success = await _repository.rateAppointment(
          appointment.id,
          selectedScore,
          comment: comment.isEmpty ? null : comment,
        );
        if (success) {
          Get.snackbar(
            'Thank You!',
            'Your rating has been submitted.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to submit rating. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }
}
