// lib/patient/features/kick_counter/widgets/kick_status_badge.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickStatusBadge extends StatelessWidget {
  final bool isActive;
  final int? kickCount;

  const KickStatusBadge({super.key, required this.isActive, this.kickCount});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _semanticFg(BuildContext context, Color base) {
    final isDark = _isDark(context);
    if (base == Colors.green)
      return isDark ? Colors.green.shade300 : Colors.green.shade800;
    if (base == Colors.orange)
      return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final greenFg = _semanticFg(context, Colors.green);
    final orangeFg = _semanticFg(context, Colors.orange);

    if (!isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          // ✅ Semantic green tint that flips with brightness
          color: Colors.green.withOpacity(isDark ? 0.20 : 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: greenFg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                TranslationKeys.kickCounterSessionComplete.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: greenFg,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: orangeFg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${TranslationKeys.kickCounterRecording.tr} ${kickCount ?? 0} ${TranslationKeys.kickCounterKicks.tr}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: orangeFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
