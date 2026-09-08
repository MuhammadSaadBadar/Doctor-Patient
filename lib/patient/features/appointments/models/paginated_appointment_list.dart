// lib/patient/features/appointments/models/paginated_appointment_list.dart

import 'package:doctor/patient/features/appointments/models/appointment.dart';

class PaginatedAppointmentList {
  final int count;
  final String? next;
  final String? previous;
  final List<Appointment> results;

  PaginatedAppointmentList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedAppointmentList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedAppointmentList(
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
