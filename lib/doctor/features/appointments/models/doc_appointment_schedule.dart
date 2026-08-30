import 'dart:ui';

import 'package:doctor/core/constants/color_constants.dart';

enum AppointmentType { inPerson, videoConsultation }

enum AppointmentStatus { pending, confirmed, completed, cancelled, noShow }

enum AppointmentPaymentStatus { pending, awaitingVerification, confirmed }

class AppointmentPayment {
  final String doctorFee;
  final String commissionPercentage;
  final String commissionAmount;
  final String totalAmount;
  final AppointmentPaymentStatus status;
  final DateTime? patientMarkedPaidAt;
  final DateTime? confirmedAt;
  final String paymentReference;

  AppointmentPayment({
    required this.doctorFee,
    required this.commissionPercentage,
    required this.commissionAmount,
    required this.totalAmount,
    required this.status,
    this.patientMarkedPaidAt,
    this.confirmedAt,
    required this.paymentReference,
  });

  factory AppointmentPayment.fromJson(Map<String, dynamic> json) {
    return AppointmentPayment(
      doctorFee: json['doctor_fee'] as String? ?? '0.00',
      commissionPercentage: json['commission_percentage'] as String? ?? '0.00',
      commissionAmount: json['commission_amount'] as String? ?? '0.00',
      totalAmount: json['total_amount'] as String? ?? '0.00',
      status: _parsePaymentStatus(json['status'] as String? ?? 'pending'),
      patientMarkedPaidAt: json['patient_marked_paid_at'] != null
          ? DateTime.parse(json['patient_marked_paid_at'] as String)
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      paymentReference: json['payment_reference'] as String? ?? '',
    );
  }

  static AppointmentPaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'awaiting_verification':
        return AppointmentPaymentStatus.awaitingVerification;
      case 'confirmed':
        return AppointmentPaymentStatus.confirmed;
      case 'pending':
      default:
        return AppointmentPaymentStatus.pending;
    }
  }

  String get statusDisplay {
    switch (status) {
      case AppointmentPaymentStatus.pending:
        return 'Pending';
      case AppointmentPaymentStatus.awaitingVerification:
        return 'Awaiting Verification';
      case AppointmentPaymentStatus.confirmed:
        return 'Confirmed';
    }
  }

  Color get statusColor {
    switch (status) {
      case AppointmentPaymentStatus.pending:
        return AppColors.onErrorContainer;
      case AppointmentPaymentStatus.awaitingVerification:
        return AppColors.primary;
      case AppointmentPaymentStatus.confirmed:
        return AppColors.secondaryContainer;
    }
  }
}

class BriefUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  BriefUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory BriefUser.fromJson(Map<String, dynamic> json) {
    return BriefUser(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}

class AppointmentSchedule {
  final int id;
  final BriefUser patient;
  final BriefUser doctor;
  final AppointmentType type;
  final DateTime scheduledAt;
  final int durationMinutes;
  final AppointmentStatus status;
  final String meetingLink;
  final String reason;
  final String doctorNotes;
  final String cancellationReason;
  final AppointmentPayment? payment;
  final DateTime createdAt;
  final DateTime updatedAt;
  // New fields from Phase 17
  final DoctorContact? doctorContact;
  final DoctorPayout? doctorPayout;

  AppointmentSchedule({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.type,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.meetingLink,
    required this.reason,
    required this.doctorNotes,
    required this.cancellationReason,
    this.payment,
    required this.createdAt,
    required this.updatedAt,
    this.doctorContact,
    this.doctorPayout,
  });

  factory AppointmentSchedule.fromJson(Map<String, dynamic> json) {
    return AppointmentSchedule(
      id: json['id'] as int,
      patient: BriefUser.fromJson(json['patient'] as Map<String, dynamic>),
      doctor: BriefUser.fromJson(json['doctor'] as Map<String, dynamic>),
      type: _parseAppointmentType(
        json['appointment_type'] as String? ?? 'in_person',
      ),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      status: _parseAppointmentStatus(json['status'] as String? ?? 'pending'),
      meetingLink: json['meeting_link'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      doctorNotes: json['doctor_notes'] as String? ?? '',
      cancellationReason: json['cancellation_reason'] as String? ?? '',
      payment: json['payment'] != null
          ? AppointmentPayment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      doctorContact: json['doctor_contact'] != null
          ? DoctorContact.fromJson(json['doctor_contact'] as Map<String, dynamic>)
          : null,
      doctorPayout: json['doctor_payout'] != null
          ? DoctorPayout.fromJson(json['doctor_payout'] as Map<String, dynamic>)
          : null,
    );
  }

  static AppointmentType _parseAppointmentType(String type) {
    switch (type) {
      case 'video_consultation':
        return AppointmentType.videoConsultation;
      case 'in_person':
      default:
        return AppointmentType.inPerson;
    }
  }

  static AppointmentStatus _parseAppointmentStatus(String status) {
    switch (status) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      case 'pending':
      default:
        return AppointmentStatus.pending;
    }
  }

  // Getters for UI
  String get typeDisplay {
    switch (type) {
      case AppointmentType.inPerson:
        return 'In Person';
      case AppointmentType.videoConsultation:
        return 'Video Consultation';
    }
  }

  String get statusDisplay {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.onErrorContainer;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.secondaryContainer;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return AppColors.errorContainer;
    }
  }

  Color get typeColor {
    switch (type) {
      case AppointmentType.inPerson:
        return AppColors.primaryContainer;
      case AppointmentType.videoConsultation:
        return AppColors.secondaryContainer;
    }
  }

  Color get typeTextColor {
    switch (type) {
      case AppointmentType.inPerson:
        return AppColors.onPrimaryContainer;
      case AppointmentType.videoConsultation:
        return AppColors.onSecondaryContainer;
    }
  }

  DateTime get date =>
      DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);

  String get time {
    final hour = scheduledAt.hour;
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get patientName => patient.fullName;
  String get patientInitials => patient.initials;
  String? get patientImageUrl => null;
  String get doctorName => doctor.fullName;
  bool get hasWarning =>
      status == AppointmentStatus.cancelled ||
      status == AppointmentStatus.noShow;

  // For backward compatibility with existing widgets
  String get name => patient.fullName;
  String? get imageUrl => null;
}

// ============ NEW MODELS FOR PHASE 17 ============

class DoctorContact {
  final String? phoneNumber;

  DoctorContact({this.phoneNumber});

  factory DoctorContact.fromJson(Map<String, dynamic> json) {
    return DoctorContact(
      phoneNumber: json['phone_number'] as String?,
    );
  }
}

class DoctorPayout {
  final String status; // 'pending' or 'paid'
  final String amount;

  DoctorPayout({required this.status, required this.amount});

  factory DoctorPayout.fromJson(Map<String, dynamic> json) {
    return DoctorPayout(
      status: json['status'] as String? ?? 'pending',
      amount: json['amount'] as String? ?? '0.00',
    );
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }
}
