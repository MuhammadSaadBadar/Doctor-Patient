// import 'package:flutter/material.dart';

// class AppColors {
//   AppColors._();

//   // ── Primary ───────────────────────────────────────────────────────────────
//   static const Color primary = Color(0xFF0F2D56); // main navy
//   static const Color onPrimary = Color(0xFFFFFFFF);
//   static const Color primaryDark = Color(0xFF0A2040); // deepest navy
//   static const Color primaryContainer = Color(0xFF1A4A80); // lighter navy
//   static const Color onPrimaryContainer = Color(0xFFB6C6EF);
//   static const Color primaryFixed = Color(0xFFD8E2FF);
//   static const Color onPrimaryFixed = Color(0xFF0A2040);
//   static const Color primaryFixedDim = Color(0xFFB6C6EF);
//   static const Color inversePrimary = Color(0xFFB6C6EF);
//   static const Color onPrimaryFixedVariant = Color(0xFF364768);

//   /// Tinted surface — field background on focus, section highlights.
//   static const Color primarySubtle = Color(0xFFF5F9FF);

//   /// Muted navy — secondary text, icons, labels.
//   static const Color primaryMuted = Color(0xFF5A7395);

//   // ── Secondary / Accent ────────────────────────────────────────────────────
//   static const Color secondary = Color(0xFF1A6FC4); // bright blue
//   static const Color onSecondary = Color(0xFFFFFFFF);
//   static const Color secondaryContainer = Color(0xFF2589E0); // medium blue
//   static const Color onSecondaryContainer = Color(0xFF001E2F);
//   static const Color secondaryFixed = Color(0xFF4AA8FF); // sky blue
//   static const Color onSecondaryFixed = Color(0xFF001E2F);
//   static const Color secondaryFixedDim = Color(0xFF2589E0);
//   static const Color onSecondaryFixedVariant = Color(0xFF004B6F);

//   /// Light tint for secondary — info chips, tags, badges.
//   static const Color secondarySubtle = Color(0xFFEEF6FF);

//   // ── Tertiary ─────────────────────────────────────────────────────────────
//   static const Color tertiary = Color(0xFF0D1B2A); // near-black
//   static const Color onTertiary = Color(0xFFFFFFFF);
//   static const Color tertiaryContainer = Color(0xFF1B2E44);
//   static const Color onTertiaryContainer = Color(0xFFB0C4D8);

//   // ── Semantic: Success ─────────────────────────────────────────────────────
//   static const Color success = Color(0xFF16A34A);
//   static const Color onSuccess = Color(0xFFFFFFFF);
//   static const Color successContainer = Color(0xFFDCFCE7);
//   static const Color onSuccessContainer = Color(0xFF14532D);
//   static const Color successSubtle = Color(0xFFF0FDF4);

//   // ── Semantic: Warning ─────────────────────────────────────────────────────
//   static const Color warning = Color(0xFFD97706);
//   static const Color onWarning = Color(0xFFFFFFFF);
//   static const Color warningContainer = Color(0xFFFEF3C7);
//   static const Color onWarningContainer = Color(0xFF92400E);
//   static const Color warningSubtle = Color(0xFFFFFBEB);

//   // ── Surface ───────────────────────────────────────────────────────────────
//   static const Color surface = Color(0xFFFFFFFF);
//   static const Color surfaceBright = Color(0xFFFFFFFF);
//   static const Color surfaceDim = Color(0xFFDDE6F0);
//   static const Color surfaceContainer = Color(0xFFE8EEF5); // card border
//   static const Color surfaceContainerLow = Color(0xFFF0F4F8); // app background
//   static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
//   static const Color surfaceContainerHigh = Color(0xFFDDE6F0);
//   static const Color surfaceContainerHighest = Color(0xFFC8D8E8);
//   static const Color surfaceVariant = Color(0xFFE8EEF5);
//   static const Color onSurface = Color(0xFF0D1B2A);
//   static const Color onSurfaceVariant = Color(0xFF5A7395);
//   static const Color inverseSurface = Color(0xFF0D1B2A);
//   static const Color inverseOnSurface = Color(0xFFF0F4F8);

//   // ── Error ─────────────────────────────────────────────────────────────────
//   static const Color error = Color(0xFFDC2626);
//   static const Color onError = Color(0xFFFFFFFF);
//   static const Color errorContainer = Color(0xFFFFE4E4);
//   static const Color onErrorContainer = Color(0xFF7F1D1D);
//   static const Color errorSubtle = Color(0xFFFFF5F5);

//   // ── Background ────────────────────────────────────────────────────────────
//   static const Color background = Color(0xFFF0F4F8);
//   static const Color onBackground = Color(0xFF0D1B2A);

//   // ── Outline ───────────────────────────────────────────────────────────────
//   static const Color outline = Color(0xFFB0C4D8); // placeholder text
//   static const Color outlineVariant = Color(0xFFC8D8E8); // hairlines
//   static const Color outlineSubtle = Color(0xFFDDE6F0); // field borders

//   // ── Misc ──────────────────────────────────────────────────────────────────
//   static const Color surfaceTint = Color(0xFF1A6FC4);
//   static const Color cardShadow = Color(0x0D0F2D56); // primary @ 5%
//   static const Color primaryWithOpacity = Color(0x1A0F2D56); // primary @ 10%

//   // ── Gradients ─────────────────────────────────────────────────────────────
//   static const LinearGradient primaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [Color(0xFF0A2040), Color(0xFF0F2D56), Color(0xFF1A4A80)],
//     stops: [0.0, 0.55, 1.0],
//   );

//   static const LinearGradient accentGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [Color(0xFF1A6FC4), Color(0xFF2589E0)],
//   );

//   static const LinearGradient saveBarGradient = LinearGradient(
//     begin: Alignment.centerLeft,
//     end: Alignment.centerRight,
//     colors: [Color(0xFF2589E0), Color(0xFF4AA8FF)],
//   );
// }
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF008080); // brand teal
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF003737); // deepest teal ink
  static const Color primaryContainer = Color(0xFFE0F2F1); // lighter teal
  static const Color onPrimaryContainer = Color(0xFF004D40);
  static const Color primaryFixed = Color(0xFFD2EBE3);
  static const Color onPrimaryFixed = Color(0xFF003737);
  static const Color primaryFixedDim = Color(0xFFA1E0CC);
  static const Color inversePrimary = Color(0xFFA1E0CC);
  static const Color onPrimaryFixedVariant = Color(0xFF007070);

  /// Tinted surface — field background on focus, section highlights.
  static const Color primarySubtle = Color(0xFFF6FFFB); // soft white glow

  /// Muted teal — secondary text, icons, labels.
  static const Color primaryMuted = Color(0xFF007070);

  // ── Secondary / Accent ────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF00C6C6); // bright cyan/teal
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE0FDFD);
  static const Color onSecondaryContainer = Color(0xFF007070);
  static const Color secondaryFixed = Color(0xFF009B9B);
  static const Color onSecondaryFixed = Color(0xFF003737);
  static const Color secondaryFixedDim = Color(0xFF007070);
  static const Color onSecondaryFixedVariant = Color(0xFF004D40);

  /// Light tint for secondary — info chips, tags, badges.
  static const Color secondarySubtle = Color(0xFFE0FDFD);

  // ── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF003737); // near-black teal (ink)
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF004D40);
  static const Color onTertiaryContainer = Color(0xFFE0F2F1);

  // ── Semantic: Success ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF34A853);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFE4F7EA);
  static const Color onSuccessContainer = Color(0xFF14532D);
  static const Color successSubtle = Color(0xFFF0FDF4);

  // ── Semantic: Warning ─────────────────────────────────────────────────────
  static const Color warning = Color(0xFFF5A623);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF1D9);
  static const Color onWarningContainer = Color(0xFF92400E);
  static const Color warningSubtle = Color(0xFFFFFBEB);

  // ── Surface ───────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFEFF2F0);
  static const Color surfaceContainer = Color(0xFFEEEEEE); // card border
  static const Color surfaceContainerLow = Color(0xFFF9F9F9); // app background
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFF4F4F4);
  static const Color surfaceContainerHighest = Color(0xFFE1E6E3);
  static const Color surfaceVariant = Color(0xFFF4F4F4);
  static const Color onSurface = Color(0xFF003737);
  static const Color onSurfaceVariant = Color(0xFF007070);
  static const Color inverseSurface = Color(0xFF1E2A2E);
  static const Color inverseOnSurface = Color(0xFFFFFFFF);

  // ── Error ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFE05252);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFE5E5);
  static const Color onErrorContainer = Color(0xFF8B2020);
  static const Color errorSubtle = Color(0xFFFFF5F5);

  // ── Background ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF003737);

  // ── Outline ───────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF009B9B); // placeholder text
  static const Color outlineVariant = Color(0xFFEEEEEE); // hairlines
  static const Color outlineSubtle = Color(0xFFF4F4F4); // field borders

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color surfaceTint = Color(0xFF008080);
  static const Color cardShadow = Color(0x0D003737); // dark ink @ 5%
  static const Color primaryWithOpacity = Color(0x1A008080); // primary @ 10%

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF003737), Color(0xFF008080), Color(0xFF009B9B)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C6C6), Color(0xFF009B9B)],
  );

  static const LinearGradient saveBarGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF009B9B), Color(0xFF00C6C6)],
  );
}
