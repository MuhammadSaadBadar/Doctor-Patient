// lib/patient/features/surgical_procedures/models/paginated_procedure_list.dart

import 'package:doctor/patient/features/surgical_procedures/models/surgical_procedure.dart';

class PaginatedProcedureList {
  final int count;
  final String? next;
  final String? previous;
  final List<SurgicalProcedure> results;

  PaginatedProcedureList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedProcedureList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => SurgicalProcedure.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedProcedureList(
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
