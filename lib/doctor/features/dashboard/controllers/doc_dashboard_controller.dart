import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/doctor/features/dashboard/models/doc_dashboard_metric.dart';
import 'package:doctor/doctor/features/dashboard/models/doc_dashboard_alert.dart';
import 'package:doctor/doctor/features/dashboard/models/doc_dashboard_appointment.dart';
import 'package:doctor/doctor/features/dashboard/repositories/doc_dashboard_repository.dart';
import 'package:doctor/doctor/features/notifications/repositories/doc_notification_repository.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_profile_repository.dart';
import 'package:doctor/doctor/features/emergency/repositories/doc_sos_repository.dart';
import 'package:doctor/doctor/features/appointments/repositories/doc_appointment_repository.dart';
import 'package:doctor/doctor/features/appointments/models/doc_appointment_schedule.dart';

class DoctorDashboardController extends GetxController {
  final DoctorDashboardRepository _repository = DoctorDashboardRepository();
  final DoctorProfileRepository _profileRepository = DoctorProfileRepository();
  final DoctorNotificationRepository _notificationRepository =
      DoctorNotificationRepository();
  final DoctorSosRepository _sosRepository = DoctorSosRepository();
  final DoctorAppointmentRepository _appointmentRepository =
      DoctorAppointmentRepository();

  // State variables
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data lists
  final metrics = <DashboardMetric>[].obs;
  final appointments = <DashboardAppointment>[].obs;
  final alerts = <DashboardAlert>[].obs;

  // Doctor info
  final doctorName = ''.obs;

  // Unread notification count
  final unreadNotificationCount = 0.obs;

  // Active SOS count
  final activeSosCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load doctor name from API
    _loadDoctorName();
    // Load dashboard data
    loadDashboardData();
    // Load unread notification count
    refreshUnreadCount();
  }

  Future<void> _loadDoctorName() async {
    try {
      final userProfile = await _profileRepository.getUserProfile();
      if (userProfile != null && userProfile.fullName.isNotEmpty) {
        doctorName.value = 'Dr. ${userProfile.fullName}';
      }
    } catch (e) {
      debugPrint('[DASHBOARD] Error loading doctor name: $e');
    }
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Fetch dashboard data, active SOS count, and filtered appointment counts in parallel
      final results = await Future.wait([
        _repository.getDoctorDashboard(),
        _sosRepository.getActiveSosCount(),
        DoctorAppointmentRepository().getFilteredAppointmentCounts(),
      ]);

      final dashboardData = results[0] as DoctorDashboardData?;
      final sosCount = results[1] as int;
      final filteredCounts =
          results[2]
              as ({
                int upcomingConfirmedPaid,
                int completed,
                int totalFiltered,
              });

      if (dashboardData != null) {
        // Update active SOS count from emergency endpoint
        activeSosCount.value = sosCount;

        // Update metrics
        metrics.value = _buildMetrics(
          dashboardData,
          filteredCounts.totalFiltered,
        );

        // Update appointments
        appointments.value = _buildAppointments(dashboardData);

        // Update alerts
        alerts.value = _buildAlerts(dashboardData);

        // Update unread notification count
        unreadNotificationCount.value =
            dashboardData.unreadNotificationsCount ?? 0;

        // Update doctor name if available
        // doctorName.value = dashboardData.doctorName; // Removed - handled in _loadDoctorName()

        debugPrint('[DASHBOARD] Data loaded successfully');
      } else {
        // API returned null - show empty state
        metrics.clear();
        appointments.clear();
        alerts.clear();
        unreadNotificationCount.value = 0;
        debugPrint('[DASHBOARD] No data returned from API');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load dashboard data. Please try again.';
      debugPrint('[DASHBOARD] Error loading data: $e');
      // Clear data on error - show error state in UI
      metrics.clear();
      appointments.clear();
      alerts.clear();
      unreadNotificationCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  List<DashboardMetric> _buildMetrics(
    DoctorDashboardData data,
    int filteredTotalAppointments,
  ) {
    return [
      DashboardMetric(
        id: 'total_patients',
        iconName: 'group',
        iconBgColor: AppColors.primaryFixed,
        iconColor: AppColors.onPrimaryFixed,
        label: 'Total Patients',
        value: data.totalAssignedPatients?.toString() ?? '0',
        badge: data.totalAssignedPatients != null ? 'Active' : null,
        badgeColor: AppColors.secondaryFixed,
        badgeTextColor: AppColors.onSecondaryFixedVariant,
      ),
      DashboardMetric(
        id: 'todays_appointments',
        iconName: 'event',
        iconBgColor: AppColors.tertiary,
        iconColor: AppColors.onTertiary,
        label: "Today's Appointments",
        value: data.todayAppointments?.toString() ?? '0',
        badge: data.todayAppointments != null && data.todayAppointments! > 0
            ? 'Today'
            : null,
        badgeColor: Colors.transparent,
        badgeTextColor: AppColors.onSurfaceVariant,
      ),
      DashboardMetric(
        id: 'pending_actions',
        iconName: 'warning',
        iconBgColor: AppColors.errorContainer,
        iconColor: AppColors.onErrorContainer,
        label: 'Pending Actions',
        value:
            (data.pendingAppointments ?? 0) +
                    (data.paymentsAwaitingConfirmation ?? 0) >
                0
            ? '${(data.pendingAppointments ?? 0) + (data.paymentsAwaitingConfirmation ?? 0)}'
            : '0',
        badge: 'Action',
        badgeColor: AppColors.errorContainer,
        badgeTextColor: AppColors.onErrorContainer,
      ),
      DashboardMetric(
        id: 'average_rating',
        iconName: 'star',
        iconBgColor: AppColors.surfaceVariant,
        iconColor: AppColors.onSurfaceVariant,
        label: 'Average Rating',
        value: data.averageRating?.toStringAsFixed(1) ?? '0.0',
        badge: data.totalRatings != null
            ? '${data.totalRatings} reviews'
            : null,
        badgeColor: Colors.transparent,
        badgeTextColor: AppColors.onSurfaceVariant,
        showOnMobile: false,
      ),
      // New earnings metrics (Phase 17)
      DashboardMetric(
        id: 'total_earnings',
        iconName: 'payments',
        iconBgColor: AppColors.secondaryFixed,
        iconColor: AppColors.onSecondaryFixed,
        label: 'Total Earnings',
        value: data.totalEarningsReceived != null
            ? 'Rs. ${data.totalEarningsReceived!.toStringAsFixed(0)}'
            : 'Rs. 0',
        badge: 'Received',
        badgeColor: AppColors.successContainer,
        badgeTextColor: AppColors.onSuccessContainer,
      ),
      DashboardMetric(
        id: 'pending_payout',
        iconName: 'hourglass_empty',
        iconBgColor: AppColors.warningContainer,
        iconColor: AppColors.onWarningContainer,
        label: 'Pending Payout',
        value: data.pendingPayoutAmount != null
            ? 'Rs. ${data.pendingPayoutAmount!.toStringAsFixed(0)}'
            : 'Rs. 0',
        badge: 'Pending',
        badgeColor: AppColors.warningContainer,
        badgeTextColor: AppColors.onWarningContainer,
      ),
      DashboardMetric(
        id: 'total_appointments',
        iconName: 'calendar_today',
        iconBgColor: AppColors.tertiary,
        iconColor: AppColors.onTertiary,
        label: 'Total Appointments',
        value: filteredTotalAppointments.toString(),
        badge: 'Upcoming + Completed',
        badgeColor: AppColors.tertiary,
        badgeTextColor: AppColors.onTertiary,
      ),
      // Emergency metric
      DashboardMetric(
        id: 'active_sos',
        iconName: 'emergency',
        iconBgColor: AppColors.errorContainer,
        iconColor: AppColors.onErrorContainer,
        label: 'Active SOS',
        value: activeSosCount.value.toString(),
        badge: activeSosCount.value > 0 ? 'Active' : null,
        badgeColor: AppColors.errorContainer,
        badgeTextColor: AppColors.onErrorContainer,
      ),
    ];
  }

  List<DashboardAppointment> _buildAppointments(DoctorDashboardData data) {
    if (data.upcomingAppointments == null ||
        data.upcomingAppointments!.isEmpty) {
      return [];
    }

    return data.upcomingAppointments!.map((json) {
      final appointment = DashboardAppointment.fromJson(json);
      // Set isUpNext for the first appointment
      if (data.upcomingAppointments!.indexOf(json) == 0) {
        // We need to create a new instance with isUpNext true
        return DashboardAppointment(
          id: appointment.id,
          initials: appointment.initials,
          name: appointment.name,
          type: appointment.type,
          icon: appointment.icon,
          time: appointment.time,
          duration: appointment.duration,
          isUpNext: true,
        );
      }
      return appointment;
    }).toList();
  }

  List<DashboardAlert> _buildAlerts(DoctorDashboardData data) {
    // Create alerts from the dashboard data
    final alertsList = <DashboardAlert>[];

    // Check for pending appointments
    if (data.pendingAppointments != null && data.pendingAppointments! > 0) {
      alertsList.add(
        DashboardAlert(
          id: 'pending',
          name: 'System',
          message:
              'You have ${data.pendingAppointments} pending appointments to review.',
          type: AlertType.pending,
          actionText: 'Review',
        ),
      );
    }

    // Check for payments awaiting confirmation
    if (data.paymentsAwaitingConfirmation != null &&
        data.paymentsAwaitingConfirmation! > 0) {
      alertsList.add(
        DashboardAlert(
          id: 'payment',
          name: 'System',
          message:
              '${data.paymentsAwaitingConfirmation} patients are awaiting payment confirmation.',
          type: AlertType.pending,
          actionText: 'Confirm Payments',
        ),
      );
    }

    return alertsList;
  }

  void refreshDashboard() {
    loadDashboardData();
  }

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _notificationRepository.getUnreadCount();
      unreadNotificationCount.value = count;
    } catch (e) {
      debugPrint('[DASHBOARD] Error refreshing unread count: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

// Data class for doctor dashboard response
class DoctorDashboardData {
  final int? totalAssignedPatients;
  final int? todayAppointments;
  final int? pendingAppointments;
  final List<Map<String, dynamic>>? upcomingAppointments;
  final int? completedAppointmentsCount;
  final double? averageRating;
  final int? totalRatings;
  final int? unreadNotificationsCount;
  final int? paymentsAwaitingConfirmation;
  // New fields from Phase 17
  final int? totalAppointments;
  final double? totalEarningsReceived;
  final double? pendingPayoutAmount;

  DoctorDashboardData({
    this.totalAssignedPatients,
    this.todayAppointments,
    this.pendingAppointments,
    this.upcomingAppointments,
    this.completedAppointmentsCount,
    this.averageRating,
    this.totalRatings,
    this.unreadNotificationsCount,
    this.paymentsAwaitingConfirmation,
    this.totalAppointments,
    this.totalEarningsReceived,
    this.pendingPayoutAmount,
  });

  factory DoctorDashboardData.fromJson(Map<String, dynamic> json) {
    return DoctorDashboardData(
      totalAssignedPatients: json['total_assigned_patients'] as int?,
      todayAppointments: json['today_appointments'] as int?,
      pendingAppointments: json['pending_appointments'] as int?,
      upcomingAppointments: (json['upcoming_appointments'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      completedAppointmentsCount: json['completed_appointments_count'] as int?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalRatings: json['total_ratings'] as int?,
      unreadNotificationsCount: json['unread_notifications_count'] as int?,
      paymentsAwaitingConfirmation:
          json['payments_awaiting_my_confirmation'] as int?,
      totalAppointments: json['total_appointments'] as int?,
      totalEarningsReceived: (json['total_earnings_received'] as num?)
          ?.toDouble(),
      pendingPayoutAmount: (json['pending_payout_amount'] as num?)?.toDouble(),
    );
  }
}
