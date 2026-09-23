// lib/patient/features/exercise_videos/screens/exercise_videos_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/exercise_videos/controllers/exercise_video_controller.dart';
import 'package:doctor/patient/features/exercise_videos/models/exercise_video.dart';
import 'package:doctor/patient/features/exercise_videos/widgets/filter_chip.dart';
import 'package:doctor/patient/features/exercise_videos/widgets/video_card.dart';
import 'package:doctor/patient/features/exercise_videos/widgets/video_player_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExerciseVideosScreen extends GetView<ExerciseVideoController> {
  const ExerciseVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PatientTopAppBar(
        title: TranslationKeys.exerciseTitle.tr,
        trailingActions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: cs.primary),
            onPressed: () => _openSearch(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.videos.isEmpty) {
          return _buildLoadingState(context);
        }
        if (controller.hasError.value && controller.videos.isEmpty) {
          return _buildErrorState(context);
        }
        if (controller.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildContent(context);
      }),
    );
  }

  void _openSearch(BuildContext context) {
    final initial = controller.searchQuery.value;
    showSearch(
      context: context,
      delegate: _ExerciseSearchDelegate(
        initialQuery: initial,
        onChanged: controller.setSearchQuery,
      ),
    );
  }

  void _playVideo(ExerciseVideo video) {
    Get.to(
      () => VideoPlayerOverlay(video: video),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
    );
  }

  Widget _buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: cs.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
          children: [
            _buildHeroHeader(context),
            const SizedBox(height: 16),
            _buildFilterChips(context),
            const SizedBox(height: 16),
            _buildVideoGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            cs.primary.withValues(alpha: 0.06),
            cs.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ Added
              children: [
                Text(
                  TranslationKeys.exerciseGentleMovement.tr,
                  style: TextStyle(
                    fontSize: textScale.scale(22).clamp(18.0, 28.0),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // ✅ Removed Flexible wrapper
                  TranslationKeys.exerciseSubtitle.tr,
                  style: TextStyle(
                    fontSize: textScale.scale(12).clamp(10.0, 16.0),
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.self_improvement_rounded,
              size: 24,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      controller.selectedFilter.value;
      // ✅ Fixed: Added SizedBox with explicit height for horizontal ListView
      return SizedBox(
        height: 44, // Fixed height for horizontal ListView
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.filters.length,
          itemBuilder: (context, index) {
            final filter = controller.filters[index];
            final id = filter['id'] as String;
            final labelKey = filter['label'] as String;
            final label = id.startsWith('t')
                ? labelKey.tr.replaceAll('@number', id.substring(1))
                : labelKey.tr;
            final icon = filter['icon'] as IconData;
            final isSelected = controller.selectedFilter.value == id;
            final count = controller.getFilterCount(id);

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ExerciseFilterChip(
                id: id,
                label: label,
                icon: icon,
                isSelected: isSelected,
                count: count,
                color: cs.primary,
                onTap: () => controller.setFilter(id),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildVideoGrid(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Obx(() {
      final list = controller.filteredVideos;
      if (list.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: Text(
              TranslationKeys.exerciseNoMatch.tr,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      // ✅ Each video takes full width (one per row)
      return Column(
        mainAxisSize: MainAxisSize.min, // ✅ Added
        children: list.map((video) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: VideoCard(video: video, onTap: () => _playVideo(video)),
          );
        }).toList(),
      );
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            TranslationKeys.exerciseLoading.tr,
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 16.0),
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ Added
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: cs.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.commonSomethingWentWrong.tr,
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 20.0),
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // ✅ Removed Flexible wrapper
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(TranslationKeys.exerciseTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ Added
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_rounded,
                size: 40,
                color: cs.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.exerciseNoVideos.tr,
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 22.0),
                fontWeight: FontWeight.w700,
                fontFamily: 'PlayfairDisplay',
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // ✅ Removed Flexible wrapper
              TranslationKeys.exerciseNoVideosDesc.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(TranslationKeys.exerciseRefresh.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSearchDelegate extends SearchDelegate<String> {
  final ValueChanged<String> onChanged;

  _ExerciseSearchDelegate({
    required String initialQuery,
    required this.onChanged,
  }) : super(searchFieldLabel: TranslationKeys.exerciseSearchHint.tr);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          query = '';
          onChanged('');
        },
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) {
    onChanged(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onChanged(query);
    return const SizedBox.shrink();
  }
}
