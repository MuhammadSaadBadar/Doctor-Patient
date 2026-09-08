// lib/patient/features/medicine_reminders/models/paginated_intake_log_list.dart

import 'package:doctor/patient/features/medicine_reminders/models/medicine_intake_log.dart';

class PaginatedIntakeLogList {
  final int count;
  final String? next;
  final String? previous;
  final List<MedicineIntakeLog> results;

  PaginatedIntakeLogList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedIntakeLogList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => MedicineIntakeLog.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedIntakeLogList(
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
