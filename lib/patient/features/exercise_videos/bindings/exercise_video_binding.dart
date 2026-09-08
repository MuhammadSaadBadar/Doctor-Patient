// lib/patient/features/exercise_videos/bindings/exercise_video_binding.dart

import 'package:doctor/patient/features/exercise_videos/controllers/exercise_video_controller.dart';
import 'package:doctor/patient/features/exercise_videos/repositories/exercise_video_repository.dart';
import 'package:get/get.dart';

class ExerciseVideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExerciseVideoRepository>(() => ExerciseVideoRepository());
    Get.lazyPut<ExerciseVideoController>(() => ExerciseVideoController());
  }
}
