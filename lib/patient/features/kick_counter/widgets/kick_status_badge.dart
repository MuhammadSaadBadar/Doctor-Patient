// lib/patient/features/kick_counter/widgets/kick_status_badge.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickStatusBadge extends StatelessWidget {
  final bool isActive;
  final int? kickCount;

  const KickStatusBadge({super.key, required this.isActive, this.kickCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: Colors.green.shade700,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                TranslationKeys.kickCounterSessionComplete.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
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
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
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
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
