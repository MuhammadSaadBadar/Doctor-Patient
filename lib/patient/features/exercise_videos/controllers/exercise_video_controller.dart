// lib/patient/features/exercise_videos/controllers/exercise_video_controller.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/patient/features/exercise_videos/models/exercise_video.dart';
import 'package:doctor/patient/features/exercise_videos/repositories/exercise_video_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Filter ids used by the chip row. Trimester ids are encoded as `t1/t2/t3`
/// so they survive static string-based UI mapping cleanly.
class _FilterIds {
  static const String all = 'all';
  static const String exercise = 'exercise';
  static const String breathing = 'breathing';
  static String trimester(int t) => 't$t';
}

class ExerciseVideoController extends GetxController {
  ExerciseVideoController({ExerciseVideoRepository? repository})
    : _repository = repository ?? Get.find<ExerciseVideoRepository>();

  final ExerciseVideoRepository _repository;

  // --- list state ---
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final videos = <ExerciseVideo>[].obs;
  final filteredVideos = <ExerciseVideo>[].obs;
  final totalCount = 0.obs;

  // --- filters ---
  final selectedFilter = _FilterIds.all.obs;
  final searchQuery = ''.obs;
  final filters = <Map<String, dynamic>>[
    {
      'id': _FilterIds.all,
      'label': TranslationKeys.exerciseAll,
      'icon': Icons.grid_view_rounded,
    },
    {
      'id': _FilterIds.exercise,
      'label': TranslationKeys.exerciseExercise,
      'icon': Icons.fitness_center_rounded,
    },
    {
      'id': _FilterIds.breathing,
      'label': TranslationKeys.exerciseBreathing,
      'icon': Icons.air_rounded,
    },
    {
      'id': _FilterIds.trimester(1),
      'label': TranslationKeys.exerciseTrimester,
      'icon': Icons.spa_rounded,
    },
    {
      'id': _FilterIds.trimester(2),
      'label': TranslationKeys.exerciseTrimester,
      'icon': Icons.spa_rounded,
    },
    {
      'id': _FilterIds.trimester(3),
      'label': TranslationKeys.exerciseTrimester,
      'icon': Icons.spa_rounded,
    },
  ];

  bool get hasVideos => videos.isNotEmpty;
  bool get isEmpty => !isLoading.value && !hasError.value && videos.isEmpty;

  @override
  void onInit() {
    super.onInit();
    // React to either filter or search changes.
    ever(selectedFilter, (_) => _applyFilter());
    ever(searchQuery, (_) => _applyFilter());
    loadVideos();
  }

  @override
  void onClose() {
    // The VideoPlayerManager owns its own lifecycle and is disposed
    // when its route is popped. Nothing to release here.
    super.onClose();
  }

  // ===== data =====

  Future<void> loadVideos() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getVideos(page: 1, pageSize: 50);
      videos.assignAll(result.results);
      totalCount.value = result.count;
      _applyFilter();
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
    } catch (e) {
      debugPrint('[EXERCISE] Unexpected error: $e');
      hasError.value = true;
      errorMessage.value = TranslationKeys.exerciseLoadFailed.tr;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() => loadVideos();

  // ===== filter / search =====

  void setFilter(String filterId) {
    selectedFilter.value = filterId;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  int getFilterCount(String filterId) {
    return _filter(videos, filterId, '').length;
  }

  void _applyFilter() {
    filteredVideos.assignAll(
      _filter(videos, selectedFilter.value, searchQuery.value),
    );
  }

  List<ExerciseVideo> _filter(
    List<ExerciseVideo> source,
    String filterId,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    Iterable<ExerciseVideo> result = source;

    switch (filterId) {
      case _FilterIds.exercise:
        result = result.where((v) => v.isExercise);
        break;
      case _FilterIds.breathing:
        result = result.where((v) => v.isBreathing);
        break;
      default:
        if (filterId.startsWith('t')) {
          final trimester = int.tryParse(filterId.substring(1));
          if (trimester != null) {
            // A video either targets the trimester explicitly OR is
            // marked "all trimesters" (null). This was the original
            // semantic and matches the API description.
            result = result.where(
              (v) => v.trimester == null || v.trimester == trimester,
            );
          }
        }
    }

    if (q.isNotEmpty) {
      result = result.where((v) {
        final title = v.title.toLowerCase();
        final desc = (v.description ?? '').toLowerCase();
        return title.contains(q) || desc.contains(q);
      });
    }

    return result.toList();
  }

  // ===== navigation =====

  void navigateBack() => Get.back();

  IconData getFilterIcon(String filterId) {
    final filter = filters.firstWhereOrNull((f) => f['id'] == filterId);
    return filter?['icon'] as IconData? ?? Icons.grid_view_rounded;
  }

  String getFilterLabel(String filterId) {
    final filter = filters.firstWhereOrNull((f) => f['id'] == filterId);
    return filter?['label'] as String? ?? filterId;
  }
}
