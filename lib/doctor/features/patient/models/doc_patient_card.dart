import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

enum PatientStatus { stable, highRisk, monitoring }

class PatientCard {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final bool isActive;
  final DateTime dateJoined;
  final PatientProfile? profile;
  final PatientStatus? status;
  final String? assignedDoctorId;

  PatientCard({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.isActive,
    required this.dateJoined,
    this.profile,
    this.status,
    this.assignedDoctorId,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get patientId => '#PT-${id.toString().padLeft(4, '0')}';

  String? get imageUrl => null; // API doesn't provide image URLs

  String get week {
    if (profile?.lmpDate == null) return 'Not Set';
    // Calculate week from LMP date
    final lmpDate = profile!.lmpDate!;
    final now = DateTime.now();
    final diff = now.difference(lmpDate);
    final weeks = (diff.inDays / 7).floor();
    return 'Week $weeks';
  }

  String get nextVisit => 'Not scheduled'; // Would come from appointments API

  Color get statusColor {
    switch (status) {
      case PatientStatus.stable:
        return const Color(0xFF4CAF50);
      case PatientStatus.highRisk:
        return AppColors.error;
      case PatientStatus.monitoring:
      case null:
        return AppColors.tertiary;
    }
  }

  Color get statusBgColor {
    switch (status) {
      case PatientStatus.stable:
        return const Color(0xFFE8F5E9);
      case PatientStatus.highRisk:
        return AppColors.errorContainer;
      case PatientStatus.monitoring:
      case null:
        return AppColors.tertiary;
    }
  }

  Color get statusTextColor {
    switch (status) {
      case PatientStatus.stable:
        return const Color(0xFF1B5E20);
      case PatientStatus.highRisk:
        return AppColors.onErrorContainer;
      case PatientStatus.monitoring:
      case null:
        return AppColors.onTertiary;
    }
  }

  Color get topGradientStart {
    switch (status) {
      case PatientStatus.stable:
        return AppColors.secondaryContainer;
      case PatientStatus.highRisk:
        return AppColors.error;
      case PatientStatus.monitoring:
      case null:
        return AppColors.tertiary;
    }
  }

  Color get topGradientEnd {
    switch (status) {
      case PatientStatus.stable:
        return AppColors.secondary;
      case PatientStatus.highRisk:
        return AppColors.errorContainer;
      case PatientStatus.monitoring:
      case null:
        return AppColors.tertiaryContainer;
    }
  }

  String get statusDisplay {
    switch (status) {
      case PatientStatus.stable:
        return 'Stable';
      case PatientStatus.highRisk:
        return 'High Risk';
      case PatientStatus.monitoring:
      case null:
        return 'Monitoring';
    }
  }

  factory PatientCard.fromJson(Map<String, dynamic> json) {
    final patient = json;
    final profile = patient['patient_profile'] as Map<String, dynamic>?;

    // Status should come from API; default to null if not provided
    // TODO: Backend should provide patient status field
    PatientStatus? status;
    if (patient['status'] != null) {
      switch (patient['status'] as String) {
        case 'stable':
          status = PatientStatus.stable;
          break;
        case 'high_risk':
          status = PatientStatus.highRisk;
          break;
        case 'monitoring':
          status = PatientStatus.monitoring;
          break;
      }
    }

    return PatientCard(
      id: patient['id'] as int,
      email: patient['email'] as String,
      firstName: patient['first_name'] as String? ?? '',
      lastName: patient['last_name'] as String? ?? '',
      phoneNumber: patient['phone_number'] as String?,
      isActive: patient['is_active'] as bool? ?? true,
      dateJoined: DateTime.parse(patient['date_joined'] as String),
      profile: profile != null ? PatientProfile.fromJson(profile) : null,
      status: status,
    );
  }
}

class PatientProfile {
  final DateTime? dateOfBirth;
  final DateTime? lmpDate;
  final DateTime? eddDate;
  final String? bloodGroup;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? address;
  final bool profileComplete;

  PatientProfile({
    this.dateOfBirth,
    this.lmpDate,
    this.eddDate,
    this.bloodGroup,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.address,
    required this.profileComplete,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      lmpDate: json['lmp_date'] != null
          ? DateTime.parse(json['lmp_date'] as String)
          : null,
      eddDate: json['edd_date'] != null
          ? DateTime.parse(json['edd_date'] as String)
          : null,
      bloodGroup: json['blood_group'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      address: json['address'] as String?,
      profileComplete: json['profile_complete'] as bool? ?? false,
    );
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}
