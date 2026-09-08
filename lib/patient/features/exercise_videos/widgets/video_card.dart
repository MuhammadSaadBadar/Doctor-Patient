// lib/patient/features/exercise_videos/widgets/video_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:doctor/patient/features/exercise_videos/models/exercise_video.dart';
import 'package:doctor/patient/features/exercise_videos/models/exercise_video_ui.dart';

class VideoCard extends StatelessWidget {
  final ExerciseVideo video;
  final VoidCallback onTap;

  const VideoCard({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Fixed: Use SizedBox with fixed width for thumbnail
            SizedBox(
              width: 120,
              height: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: _thumbnailContent(cs),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        fontSize: textScale.scale(14).clamp(12.0, 18.0),
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              video.isForAllTrimesters
                                  ? video.categoryLabel
                                  : video.trimesterLabel,
                              style: TextStyle(
                                fontSize: textScale.scale(11).clamp(9.0, 14.0),
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        if (video.durationDisplay.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            video.durationDisplay,
                            style: TextStyle(
                              fontSize: textScale.scale(10).clamp(8.0, 13.0),
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Start Session',
                            style: TextStyle(
                              fontSize: textScale.scale(11).clamp(9.0, 14.0),
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailContent(ColorScheme cs) {
    final url = video.thumbnailUrl;
    if (url == null || url.isEmpty) {
      return Container(
        color: cs.surfaceContainerHigh,
        child: Icon(
          Icons.play_circle_filled_rounded,
          size: 40,
          color: cs.primary.withValues(alpha: 0.3),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: cs.surfaceContainerHigh),
      errorWidget: (_, __, ___) => Container(
        color: cs.surfaceContainerHigh,
        child: Icon(
          Icons.play_circle_filled_rounded,
          size: 40,
          color: cs.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
