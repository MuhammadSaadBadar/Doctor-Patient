// lib/patient/features/exercise_videos/models/paginated_video_list.dart

import 'package:doctor/patient/features/exercise_videos/models/exercise_video.dart';

class PaginatedVideoList {
  final int count;
  final String? next;
  final String? previous;
  final List<ExerciseVideo> results;

  PaginatedVideoList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedVideoList.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>? ?? [])
        .map((e) => ExerciseVideo.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedVideoList(
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
