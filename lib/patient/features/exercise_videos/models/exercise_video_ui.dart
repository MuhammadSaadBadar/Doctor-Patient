// lib/patient/features/exercise_videos/models/exercise_video_ui.dart

import 'package:flutter/material.dart';
import 'package:doctor/patient/features/exercise_videos/models/exercise_video.dart';

/// Presentation-only helpers. Kept out of the data class so the model
/// stays free of UI concerns.
extension ExerciseVideoUI on ExerciseVideo {
  String get categoryLabel {
    switch (category) {
      case 'breathing':
        return 'Breathing';
      case 'exercise':
      default:
        return 'Exercise';
    }
  }

  Color get categoryColor {
    return isBreathing
        ? const Color(0xFF8455EE) // Purple
        : const Color(0xFF8BA7E8); // Medical Blue
  }

  String get trimesterLabel {
    if (trimester == null) return 'All Trimesters';
    return 'Trimester $trimester';
  }

  Color get trimesterColor {
    if (trimester == null) return Colors.grey.shade400;
    switch (trimester) {
      case 1:
        return const Color(0xFF226B3F); // Green
      case 2:
        return Colors.orange.shade400;
      case 3:
        return const Color(0xFFE88B9C); // Soft Pink
      default:
        return Colors.grey.shade400;
    }
  }

  String get durationDisplay {
    if (durationMinutes == null) return '';
    return '$durationMinutes min';
  }
}
