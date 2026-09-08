// lib/patient/features/appointments/models/appointment.dart

import 'package:doctor/patient/features/appointments/models/appointment_payment.dart';
import 'package:doctor/patient/features/appointments/models/brief_user.dart';
import 'package:doctor/patient/features/appointments/models/doctor_contact.dart';
import 'package:doctor/patient/features/appointments/models/doctor_payout.dart';
import 'package:flutter/material.dart';

class Appointment {
  final int id;
  final BriefUser patient;
  final BriefUser doctor;
  final String appointmentType;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status;
  final String? meetingLink;
  final String? reason;
  final String? doctorNotes;
  final String? cancellationReason;
  final AppointmentPayment? payment;
  final DoctorContact? doctorContact;
  final DoctorPayout? doctorPayout;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? doctorSpecialization;

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.appointmentType,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.meetingLink,
    this.reason,
    this.doctorNotes,
    this.cancellationReason,
    this.payment,
    this.doctorContact,
    this.doctorPayout,
    required this.createdAt,
    required this.updatedAt,
    this.doctorSpecialization,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      patient: BriefUser.fromJson(json['patient'] ?? {}),
      doctor: BriefUser.fromJson(json['doctor'] ?? {}),
      appointmentType: json['appointment_type'] ?? 'in_person',
      scheduledAt:
          DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      durationMinutes: json['duration_minutes'] ?? 30,
      status: json['status'] ?? 'pending',
      meetingLink: json['meeting_link'],
      reason: json['reason'],
      doctorNotes: json['doctor_notes'],
      cancellationReason: json['cancellation_reason'],
      payment: json['payment'] != null
          ? AppointmentPayment.fromJson(json['payment'])
          : null,
      doctorContact: json['doctor_contact'] != null
          ? DoctorContact.fromJson(json['doctor_contact'] as Map<String, dynamic>)
          : null,
      doctorPayout: json['doctor_payout'] != null
          ? DoctorPayout.fromJson(json['doctor_payout'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      doctorSpecialization: json['doctor_specialization'],
    );
  }

  String get doctorFullName => 'Dr. ${doctor.firstName} ${doctor.lastName}';
  String get doctorSpecialty => doctorSpecialization ?? 'Specialist';

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isNoShow => status == 'no_show';

  bool get isPaid => payment?.isConfirmed ?? false;
  bool get hasPayment => payment != null;
  bool get isUnpaid => payment != null && payment!.isPending;
  bool get isAwaitingVerification =>
      payment != null && payment!.isAwaitingVerification;

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String get paymentStatusLabel {
    if (payment == null) return 'No Payment';
    switch (payment!.status) {
      case 'pending':
        return 'Unpaid';
      case 'awaiting_verification':
        return 'Awaiting Verification';
      case 'confirmed':
        return 'Paid';
      default:
        return payment!.status;
    }
  }

  Color get paymentStatusColor {
    if (payment == null) return Colors.grey;
    switch (payment!.status) {
      case 'pending':
        return Colors.orange;
      case 'awaiting_verification':
        return Colors.amber;
      case 'confirmed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get formattedDate {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    return '${weekdays[scheduledAt.weekday - 1]}, ${months[scheduledAt.month - 1]} ${scheduledAt.day}, ${scheduledAt.year}';
  }

  String get formattedTime {
    final hour = scheduledAt.hour > 12
        ? scheduledAt.hour - 12
        : (scheduledAt.hour == 0 ? 12 : scheduledAt.hour);
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    final amPm = scheduledAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  String get formattedDuration => '$durationMinutes min';

  String get formattedEndTime {
    final endTime = scheduledAt.add(Duration(minutes: durationMinutes));
    final hour = endTime.hour > 12
        ? endTime.hour - 12
        : (endTime.hour == 0 ? 12 : endTime.hour);
    final minute = endTime.minute.toString().padLeft(2, '0');
    final amPm = endTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  String get timeRange => '$formattedTime - $formattedEndTime';

  String get typeLabel {
    return appointmentType == 'video_consultation'
        ? 'Video Consultation'
        : 'In-Person Visit';
  }

  IconData get typeIcon {
    return appointmentType == 'video_consultation'
        ? Icons.videocam_rounded
        : Icons.local_hospital_rounded;
  }

  String get doctorPhone => doctorContact?.phoneNumber ?? 'N/A';
  bool get hasDoctorContact =>
      doctorContact != null && doctorContact!.phoneNumber != null;
  bool get showDoctorContact => isPaid || payment == null;
}
