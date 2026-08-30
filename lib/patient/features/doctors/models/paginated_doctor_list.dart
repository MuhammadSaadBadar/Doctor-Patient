// lib/patient/features/doctors/models/paginated_doctor_list.dart

import 'package:doctor/patient/features/doctors/models/doctor.dart';

class PaginatedDoctorList {
  final int count;
  final String? next;
  final String? previous;
  final List<Doctor> results;

  PaginatedDoctorList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedDoctorList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedDoctorList(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: resultsList,
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
}
