// lib/patient/features/doctors/models/doctor.dart

import 'package:doctor/patient/features/doctors/models/doctor_profile.dart';

class Doctor {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isActive;
  final DateTime dateJoined;
  final DoctorProfile? doctorProfile;
  final double? distanceKm;
  final double? averageRating;
  final int? totalRatings;
  final int? completedAppointmentsCount;

  Doctor({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isActive,
    required this.dateJoined,
    this.doctorProfile,
    this.distanceKm,
    this.averageRating,
    this.totalRatings,
    this.completedAppointmentsCount,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      isActive: json['is_active'] ?? true,
      dateJoined:
          DateTime.tryParse(json['date_joined'] ?? '') ?? DateTime.now(),
      doctorProfile: json['doctor_profile'] != null
          ? DoctorProfile.fromJson(json['doctor_profile'])
          : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalRatings: json['total_ratings'] as int?,
      completedAppointmentsCount: json['completed_appointments_count'] as int?,
    );
  }

  String get fullName => 'Dr. $firstName $lastName';
  String get displayName => 'Dr. $firstName $lastName';
  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return 'DR';
    return '${firstName[0]}${lastName[0]}';
  }

  bool get isAcceptingPatients =>
      doctorProfile?.isAcceptingPatients ?? false;

  String get formattedRating {
    if (averageRating == null) return 'N/A';
    return averageRating!.toStringAsFixed(1);
  }

  String get formattedCompletedVisits {
    final count = completedAppointmentsCount;
    if (count == null) return 'N/A';
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k+';
    }
    return '$count+';
  }
}
