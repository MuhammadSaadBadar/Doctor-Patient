import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/doctor/features/settings/models/doctor_profile_model.dart';
import 'package:doctor/doctor/features/settings/models/payment_method_model.dart';

class ProfileData {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final bool isEmailVerified;
  final DateTime dateJoined;
  final DoctorProfile? doctorProfile;

  ProfileData({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.isEmailVerified,
    required this.dateJoined,
    this.doctorProfile,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }
  String? get profilePictureUrl => doctorProfile?.profilePictureUrl;

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final doctorProfileData = json['doctor_profile'] as Map<String, dynamic>?;
    return ProfileData(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'doctor',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'] as String)
          : DateTime.now(),
      doctorProfile: doctorProfileData != null
          ? DoctorProfile.fromJson(doctorProfileData)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
      'date_joined': dateJoined.toIso8601String(),
      'doctor_profile': doctorProfile?.toJson(),
    };
  }

  ProfileData copyWith({
    String? id,
    String? email,
    String? role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? dateJoined,
    DoctorProfile? doctorProfile,
  }) {
    return ProfileData(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      dateJoined: dateJoined ?? this.dateJoined,
      doctorProfile: doctorProfile ?? this.doctorProfile,
    );
  }
}

class DoctorDashboardStats {
  final int? totalAssignedPatients;
  final int? todayAppointments;
  final int? pendingAppointments;
  final int? completedAppointmentsCount;
  final double? averageRating;
  final int? totalRatings;
  final int? unreadNotificationsCount;
  final int? paymentsAwaitingConfirmation;
  final List<dynamic>? upcomingAppointments; // raw list for future use

  DoctorDashboardStats({
    this.totalAssignedPatients,
    this.todayAppointments,
    this.pendingAppointments,
    this.completedAppointmentsCount,
    this.averageRating,
    this.totalRatings,
    this.unreadNotificationsCount,
    this.paymentsAwaitingConfirmation,
    this.upcomingAppointments,
  });

  factory DoctorDashboardStats.fromJson(Map<String, dynamic> json) {
    return DoctorDashboardStats(
      totalAssignedPatients: json['total_assigned_patients'] as int?,
      todayAppointments: json['today_appointments'] as int?,
      pendingAppointments: json['pending_appointments'] as int?,
      completedAppointmentsCount: json['completed_appointments_count'] as int?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalRatings: json['total_ratings'] as int?,
      unreadNotificationsCount: json['unread_notifications_count'] as int?,
      paymentsAwaitingConfirmation:
          json['payments_awaiting_my_confirmation'] as int?,
      upcomingAppointments: json['upcoming_appointments'] as List<dynamic>?,
    );
  }
}
