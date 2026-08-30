// lib/patient/features/kick_counter/models/paginated_kick_session.dart

import 'package:doctor/patient/features/kick_counter/models/kick_session.dart';

class PaginatedKickSessionList {
  final int count;
  final String? next;
  final String? previous;
  final List<KickSession> results;

  PaginatedKickSessionList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedKickSessionList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => KickSession.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedKickSessionList(
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
