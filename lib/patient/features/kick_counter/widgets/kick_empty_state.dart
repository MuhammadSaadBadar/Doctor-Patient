// lib/patient/features/kick_counter/widgets/kick_empty_state.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickEmptyState extends StatelessWidget {
  final VoidCallback? onActionTap;

  const KickEmptyState({super.key, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // ✅ Stronger tint in dark
                color: cs.primary.withOpacity(isDark ? 0.18 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.child_care_rounded,
                size: 40,
                color: cs.primary.withOpacity(isDark ? 0.7 : 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.kickCounterNoSessionsYet.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TranslationKeys.kickCounterStartTracking.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onActionTap ?? () => Get.back(),
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
              child: Text(TranslationKeys.kickCounterStartSession.tr),
            ),
          ],
        ),
      ),
    );
  }
}
