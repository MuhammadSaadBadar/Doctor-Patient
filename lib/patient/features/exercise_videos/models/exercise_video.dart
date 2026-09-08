// lib/patient/features/exercise_videos/models/exercise_video.dart

class ExerciseVideo {
  final int id;
  final String title;
  final String? description;
  final String category;
  final String videoUrl;
  final int? durationMinutes;
  final int? trimester;
  final String? thumbnailUrl;

  ExerciseVideo({
    required this.id,
    required this.title,
    required this.category,
    required this.videoUrl,
    this.description,
    this.durationMinutes,
    this.trimester,
    this.thumbnailUrl,
  });

  factory ExerciseVideo.fromJson(Map<String, dynamic> json) {
    return ExerciseVideo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      category: (json['category'] ?? 'exercise').toString(),
      videoUrl: (json['video_url'] ?? '').toString(),
      durationMinutes: json['duration_minutes'] is int
          ? json['duration_minutes'] as int
          : int.tryParse('${json['duration_minutes'] ?? ''}'),
      trimester: json['trimester'] is int
          ? json['trimester'] as int
          : int.tryParse('${json['trimester'] ?? ''}'),
      thumbnailUrl: json['thumbnail_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'video_url': videoUrl,
      'duration_minutes': durationMinutes,
      'trimester': trimester,
      'thumbnail_url': thumbnailUrl,
    };
  }

  bool get hasPlayableUrl => videoUrl.trim().isNotEmpty;
  bool get isExercise => category == 'exercise';
  bool get isBreathing => category == 'breathing';
  bool get isForAllTrimesters => trimester == null;
  bool get hasInsecureUrl {
    final lower = videoUrl.toLowerCase().trim();
    return lower.startsWith('http://');
  }
}
