// lib/patient/features/diet_plans/models/paginated_diet_plan_list.dart

import 'package:doctor/patient/features/diet_plans/models/diet_plan.dart';

class PaginatedDietPlanList {
  final int count;
  final String? next;
  final String? previous;
  final List<DietPlan> results;

  PaginatedDietPlanList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedDietPlanList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => DietPlan.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedDietPlanList(
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
