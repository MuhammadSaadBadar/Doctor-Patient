// lib/patient/features/appointment/controllers/appointment_detail_controller.dart

import 'package:doctor/patient/features/dashboard/models/dashboard_appointment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientAppointmentDetailController extends GetxController {
  final int appointmentId;
  final DashboardAppointment? initialAppointment;

  PatientAppointmentDetailController({
    required this.appointmentId,
    this.initialAppointment,
  });

  final isLoading = false.obs;
  final appointment = Rx<DashboardAppointment?>(null);

  @override
  void onInit() {
    super.onInit();
    if (initialAppointment != null) {
      appointment.value = initialAppointment;
    }
  }

  String get doctorName =>
      appointment.value?.doctorFullName ?? 'Unknown Doctor';
  String get specialization => appointment.value?.specialization ?? '';
  String get typeLabel => appointment.value?.typeLabel ?? '';
  String get status => appointment.value?.status ?? 'pending';
  bool get isConfirmed => appointment.value?.isConfirmed ?? false;
  bool get isPending => appointment.value?.isPending ?? true;
  DateTime get scheduledAt => appointment.value?.scheduledAt ?? DateTime.now();
  int get durationMinutes => appointment.value?.durationMinutes ?? 30;
  String get reason => appointment.value?.reason ?? '';
  // String get meetingLink => appointment.value?.meetingLink ?? '';

  String get formattedDate {
    final d = scheduledAt;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String get formattedTime {
    final d = scheduledAt;
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final minute = d.minute.toString().padLeft(2, '0');
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
}
