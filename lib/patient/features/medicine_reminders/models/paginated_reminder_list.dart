// lib/patient/features/medicine_reminders/models/paginated_reminder_list.dart

import 'package:doctor/patient/features/medicine_reminders/models/medicine_reminder.dart';

class PaginatedReminderList {
  final int count;
  final String? next;
  final String? previous;
  final List<MedicineReminder> results;

  PaginatedReminderList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedReminderList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => MedicineReminder.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedReminderList(
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
