import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

// class AppTheme {
//   AppTheme._();

//   static const String _fontPrimary = 'PlusJakartaSans';
//   static const String _fontSecondary = 'Times New Roman';

//   // ── Text styles ───────────────────────────────────────────────────────────

//   static const TextStyle displayLarge = TextStyle(
//     fontFamily: _fontPrimary,
//     fontSize: 40,
//     height: 52 / 40,
//     letterSpacing: -0.02,
//     fontWeight: FontWeight.w700,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle displayMedium = TextStyle(
//     fontFamily: _fontPrimary,
//     fontSize: 34,
//     height: 44 / 34,
//     letterSpacing: -0.02,
//     fontWeight: FontWeight.w700,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle displaySmall = TextStyle(
//     fontFamily: _fontPrimary,
//     fontSize: 28,
//     height: 36 / 28,
//     letterSpacing: -0.01,
//     fontWeight: FontWeight.w700,
//     color: AppColors.onSurface,
//   );

//   static const TextStyle headlineLarge = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 26,
//     height: 34 / 26,
//     letterSpacing: -0.01,
//     fontWeight: FontWeight.w700,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle headlineMedium = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 20,
//     height: 28 / 20,
//     fontWeight: FontWeight.w600,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle headlineSmall = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 17,
//     height: 24 / 17,
//     fontWeight: FontWeight.w600,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle headlineLargeMobile = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 22,
//     height: 30 / 22,
//     fontWeight: FontWeight.w700,
//     color: AppColors.onSurface,
//   );

//   static const TextStyle bodyLarge = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 16,
//     height: 24 / 16,
//     fontWeight: FontWeight.w400,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle bodyMedium = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 14,
//     height: 20 / 14,
//     fontWeight: FontWeight.w400,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle bodySmall = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 12,
//     height: 16 / 12,
//     fontWeight: FontWeight.w400,
//     color: AppColors.onSurface,
//   );

//   static const TextStyle labelLarge = TextStyle(
//     fontFamily: _fontPrimary,
//     fontSize: 13,
//     height: 18 / 13,
//     fontWeight: FontWeight.w500,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle labelMedium = TextStyle(
//     fontFamily: _fontPrimary,
//     fontSize: 11,
//     height: 14 / 11,
//     letterSpacing: 0.05,
//     fontWeight: FontWeight.w600,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle labelSmall = TextStyle(
//     fontFamily: _fontPrimary,
//     fontSize: 10,
//     height: 13 / 10,
//     letterSpacing: 0.05,
//     fontWeight: FontWeight.w500,
//     color: AppColors.onSurface,
//   );

//   static const TextStyle titleLarge = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 18,
//     height: 24 / 18,
//     fontWeight: FontWeight.w600,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle titleMedium = TextStyle(
//     fontFamily: _fontSecondary,
//     fontSize: 15,
//     height: 20 / 15,
//     fontWeight: FontWeight.w600,
//     color: AppColors.onSurface,
//   );
//   static const TextStyle titleSmall = TextStyle(
//     fontFamily: _fontPrimary,
//     fontSize: 13,
//     height: 18 / 13,
//     fontWeight: FontWeight.w500,
//     color: AppColors.onSurface,
//   );

//   // ── Light theme ───────────────────────────────────────────────────────────

//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     fontFamily: _fontPrimary,

//     colorScheme: const ColorScheme.light(
//       primary: AppColors.primary,
//       onPrimary: AppColors.onPrimary,
//       primaryContainer: AppColors.primaryContainer,
//       onPrimaryContainer: AppColors.onPrimaryContainer,
//       secondary: AppColors.secondary,
//       onSecondary: AppColors.onSecondary,
//       secondaryContainer: AppColors.secondaryContainer,
//       onSecondaryContainer: AppColors.onSecondaryContainer,
//       tertiary: AppColors.tertiary,
//       onTertiary: AppColors.onTertiary,
//       tertiaryContainer: AppColors.tertiaryContainer,
//       onTertiaryContainer: AppColors.onTertiaryContainer,
//       error: AppColors.error,
//       onError: AppColors.onError,
//       errorContainer: AppColors.errorContainer,
//       onErrorContainer: AppColors.onErrorContainer,
//       surface: AppColors.surface,
//       onSurface: AppColors.onSurface,
//       surfaceVariant: AppColors.surfaceVariant,
//       onSurfaceVariant: AppColors.onSurfaceVariant,
//       outline: AppColors.outline,
//       outlineVariant: AppColors.outlineVariant,
//       background: AppColors.background,
//       onBackground: AppColors.onBackground,
//       inverseSurface: AppColors.inverseSurface,
//       onInverseSurface: AppColors.inverseOnSurface,
//       inversePrimary: AppColors.inversePrimary,
//       surfaceTint: AppColors.surfaceTint,
//       shadow: Color(0x1A0F2D56),
//     ),

//     textTheme: const TextTheme(
//       displayLarge: displayLarge,
//       displayMedium: displayMedium,
//       displaySmall: displaySmall,
//       headlineLarge: headlineLarge,
//       headlineMedium: headlineMedium,
//       headlineSmall: headlineSmall,
//       bodyLarge: bodyLarge,
//       bodyMedium: bodyMedium,
//       bodySmall: bodySmall,
//       labelLarge: labelLarge,
//       labelMedium: labelMedium,
//       labelSmall: labelSmall,
//       titleLarge: titleLarge,
//       titleMedium: titleMedium,
//       titleSmall: titleSmall,
//     ),

//     appBarTheme: const AppBarTheme(
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       backgroundColor: AppColors.surface,
//       foregroundColor: AppColors.primary,
//       surfaceTintColor: Colors.transparent,
//       centerTitle: false,
//       titleTextStyle: headlineSmall,
//       iconTheme: IconThemeData(color: AppColors.primary, size: 22),
//       actionsIconTheme: IconThemeData(
//         color: AppColors.onSurfaceVariant,
//         size: 22,
//       ),
//     ),

//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         elevation: 0,
//         shadowColor: AppColors.cardShadow,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         minimumSize: const Size(64, 52),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         textStyle: const TextStyle(
//           fontFamily: _fontPrimary,
//           fontSize: 15,
//           fontWeight: FontWeight.w700,
//         ),
//         disabledBackgroundColor: AppColors.primaryContainer,
//         disabledForegroundColor: AppColors.onPrimary,
//       ),
//     ),

//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         side: const BorderSide(color: AppColors.outlineSubtle, width: 1.5),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         minimumSize: const Size(64, 52),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         textStyle: const TextStyle(
//           fontFamily: _fontPrimary,
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),

//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: AppColors.secondary,
//         textStyle: const TextStyle(
//           fontFamily: _fontPrimary,
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),

//     iconButtonTheme: IconButtonThemeData(
//       style: IconButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
//     ),

//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: AppColors.surfaceContainerLowest,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: AppColors.outlineSubtle),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: AppColors.outlineSubtle),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: AppColors.error),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: AppColors.error, width: 1.5),
//       ),
//       labelStyle: const TextStyle(
//         fontFamily: _fontSecondary,
//         fontSize: 13,
//         color: AppColors.onSurfaceVariant,
//       ),
//       hintStyle: const TextStyle(
//         fontFamily: _fontSecondary,
//         fontSize: 14,
//         color: AppColors.outline,
//       ),
//       errorStyle: const TextStyle(
//         fontFamily: _fontPrimary,
//         fontSize: 11,
//         color: AppColors.error,
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
//       floatingLabelStyle: const TextStyle(
//         fontFamily: _fontPrimary,
//         fontSize: 11,
//         color: AppColors.primary,
//         fontWeight: FontWeight.w600,
//       ),
//     ),

//     cardTheme: CardThemeData(
//       color: AppColors.surfaceContainerLowest,
//       surfaceTintColor: Colors.transparent,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//         side: const BorderSide(color: AppColors.surfaceContainer, width: 1),
//       ),
//       margin: EdgeInsets.zero,
//     ),

//     listTileTheme: const ListTileThemeData(
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       horizontalTitleGap: 16,
//       minVerticalPadding: 8,
//       dense: false,
//     ),

//     dividerTheme: const DividerThemeData(
//       color: AppColors.outlineSubtle,
//       thickness: 1,
//       space: 0,
//     ),

//     popupMenuTheme: const PopupMenuThemeData(
//       color: AppColors.surfaceContainerLowest,
//       surfaceTintColor: Colors.transparent,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(12)),
//       ),
//       textStyle: TextStyle(
//         fontFamily: _fontSecondary,
//         fontSize: 13,
//         color: AppColors.onSurface,
//       ),
//     ),

//     chipTheme: const ChipThemeData(
//       backgroundColor: AppColors.primarySubtle,
//       deleteIconColor: AppColors.onSurfaceVariant,
//       labelStyle: TextStyle(
//         fontFamily: _fontPrimary,
//         fontSize: 12,
//         color: AppColors.primary,
//         fontWeight: FontWeight.w500,
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       shape: StadiumBorder(),
//       side: BorderSide.none,
//     ),

//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: AppColors.surfaceContainerLowest,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: AppColors.onSurfaceVariant,
//       selectedLabelStyle: TextStyle(
//         fontFamily: _fontPrimary,
//         fontSize: 11,
//         fontWeight: FontWeight.w600,
//       ),
//       unselectedLabelStyle: TextStyle(
//         fontFamily: _fontPrimary,
//         fontSize: 11,
//         fontWeight: FontWeight.w400,
//       ),
//       elevation: 0,
//       type: BottomNavigationBarType.fixed,
//       showSelectedLabels: true,
//       showUnselectedLabels: true,
//     ),

//     snackBarTheme: const SnackBarThemeData(
//       backgroundColor: AppColors.primary,
//       contentTextStyle: TextStyle(
//         fontFamily: _fontPrimary,
//         fontSize: 13,
//         color: AppColors.onPrimary,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       behavior: SnackBarBehavior.floating,
//       elevation: 4,
//     ),

//     tooltipTheme: const TooltipThemeData(
//       decoration: BoxDecoration(
//         color: AppColors.inverseSurface,
//         borderRadius: BorderRadius.all(Radius.circular(6)),
//       ),
//       textStyle: TextStyle(
//         fontFamily: _fontPrimary,
//         fontSize: 11,
//         color: AppColors.inverseOnSurface,
//       ),
//     ),

//     materialTapTargetSize: MaterialTapTargetSize.padded,
//     visualDensity: VisualDensity.adaptivePlatformDensity,
//     pageTransitionsTheme: const PageTransitionsTheme(
//       builders: {
//         TargetPlatform.android: ZoomPageTransitionsBuilder(),
//         TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//       },
//     ),
//   );

//   // ── Dark theme ────────────────────────────────────────────────────────────

//   static ThemeData darkTheme = lightTheme.copyWith(
//     brightness: Brightness.dark,
//     colorScheme: const ColorScheme.dark(
//       primary: AppColors.primaryFixed,
//       onPrimary: AppColors.onPrimaryFixed,
//       primaryContainer: AppColors.primaryContainer,
//       onPrimaryContainer: AppColors.onPrimaryContainer,
//       secondary: AppColors.secondaryFixed,
//       onSecondary: AppColors.onSecondaryFixed,
//       secondaryContainer: AppColors.secondaryContainer,
//       onSecondaryContainer: AppColors.onSecondaryContainer,
//       error: AppColors.error,
//       onError: AppColors.onError,
//       errorContainer: AppColors.errorContainer,
//       onErrorContainer: AppColors.onErrorContainer,
//       surface: AppColors.surfaceDim,
//       onSurface: AppColors.inverseOnSurface,
//       surfaceVariant: AppColors.surfaceVariant,
//       onSurfaceVariant: AppColors.onSurfaceVariant,
//       outline: AppColors.outline,
//       outlineVariant: AppColors.outlineVariant,
//       background: AppColors.primaryDark,
//       onBackground: AppColors.inverseOnSurface,
//       inverseSurface: AppColors.surface,
//       onInverseSurface: AppColors.onSurface,
//       inversePrimary: AppColors.inversePrimary,
//     ),
//     appBarTheme: const AppBarTheme(
//       elevation: 0,
//       backgroundColor: AppColors.surfaceContainerLowest,
//       foregroundColor: AppColors.onSurface,
//       surfaceTintColor: Colors.transparent,
//       centerTitle: false,
//       titleTextStyle: headlineSmall,
//       iconTheme: IconThemeData(color: AppColors.onSurface, size: 22),
//       actionsIconTheme: IconThemeData(
//         color: AppColors.onSurfaceVariant,
//         size: 22,
//       ),
//     ),
//   );

//   // ── Theme-Aware Gradient Helpers ──────────────────────────────────────────

//   /// Returns the appropriate navigation gradient for the current theme.
//   /// Light mode: dark blue gradient (brand gradient)
//   /// Dark mode: light surface gradient
//   static LinearGradient getNavigationGradient(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     if (isDark) {
//       return LinearGradient(
//         begin: AlignmentDirectional.topStart,
//         end: AlignmentDirectional.bottomEnd,
//         colors: [
//           Theme.of(context).colorScheme.surface,
//           Theme.of(context).colorScheme.surfaceContainerLow,
//           Theme.of(context).colorScheme.surfaceContainer,
//         ],
//         stops: const [0.0, 0.55, 1.0],
//       );
//     }
//     return AppColors.primaryGradient;
//   }

//   /// Returns the appropriate navigation bar background color for the current theme.
//   static Color getNavigationBackgroundColor(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     if (isDark) {
//       return Theme.of(context).colorScheme.surfaceContainerLowest;
//     }
//     return Theme.of(context).colorScheme.surface;
//   }

//   // ── Helpers ───────────────────────────────────────────────────────────────

//   static TextStyle getResponsiveHeadline(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;
//     return isMobile ? headlineLargeMobile : headlineLarge;
//   }

//   static BoxDecoration cardDecoration({
//     Color? color,
//     double borderRadius = 20,
//     bool hasBorder = true,
//     bool hasShadow = true,
//     BuildContext? context,
//   }) {
//     final effectiveColor =
//         color ??
//         (context != null
//             ? Theme.of(context).cardTheme.color
//             : AppColors.surfaceContainerLowest);
//     final effectiveBorderColor = context != null
//         ? Theme.of(context).dividerTheme.color
//         : AppColors.surfaceContainer;
//     final effectiveShadowColor = context != null
//         ? Theme.of(context).shadowColor
//         : AppColors.cardShadow;

//     return BoxDecoration(
//       color: effectiveColor ?? AppColors.surfaceContainerLowest,
//       borderRadius: BorderRadius.circular(borderRadius),
//       border: hasBorder
//           ? Border.all(
//               color: effectiveBorderColor ?? AppColors.surfaceContainer,
//               width: 1,
//             )
//           : null,
//       boxShadow: hasShadow
//           ? [
//               BoxShadow(
//                 color: effectiveShadowColor ?? AppColors.cardShadow,
//                 blurRadius: 24,
//                 offset: const Offset(0, 8),
//               ),
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ]
//           : null,
//     );
//   }

//   static const BoxDecoration heroPanelDecoration = BoxDecoration(
//     gradient: AppColors.primaryGradient,
//     borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
//   );

//   static BoxDecoration badgeDecoration({Color? background, Color? border}) {
//     return BoxDecoration(
//       color: background ?? AppColors.primarySubtle,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: border ?? AppColors.outlineSubtle, width: 1),
//     );
//   }
// }

// // ── Context extensions ────────────────────────────────────────────────────────

// extension AppTextStyles on BuildContext {
//   TextStyle get displayLarge => AppTheme.displayLarge;
//   TextStyle get displayMedium => AppTheme.displayMedium;
//   TextStyle get displaySmall => AppTheme.displaySmall;
//   TextStyle get headlineLarge => AppTheme.headlineLarge;
//   TextStyle get headlineMedium => AppTheme.headlineMedium;
//   TextStyle get headlineSmall => AppTheme.headlineSmall;
//   TextStyle get headlineLargeMobile => AppTheme.headlineLargeMobile;
//   TextStyle get bodyLarge => AppTheme.bodyLarge;
//   TextStyle get bodyMedium => AppTheme.bodyMedium;
//   TextStyle get bodySmall => AppTheme.bodySmall;
//   TextStyle get labelLarge => AppTheme.labelLarge;
//   TextStyle get labelMedium => AppTheme.labelMedium;
//   TextStyle get labelSmall => AppTheme.labelSmall;
//   TextStyle get titleLarge => AppTheme.titleLarge;
//   TextStyle get titleMedium => AppTheme.titleMedium;
//   TextStyle get titleSmall => AppTheme.titleSmall;

//   TextStyle getResponsiveHeadline() => AppTheme.getResponsiveHeadline(this);
// }

class AppTheme {
  AppTheme._();

  static const String _fontPrimary = 'PlusJakartaSans';
  static const String _fontSecondary = 'Times New Roman';

  // ── Text styles ───────────────────────────────────────────────────────────

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontPrimary,
    fontSize: 40,
    height: 52 / 40,
    letterSpacing: -0.02,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontPrimary,
    fontSize: 34,
    height: 44 / 34,
    letterSpacing: -0.02,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontPrimary,
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: -0.01,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 26,
    height: 34 / 26,
    letterSpacing: -0.01,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static const TextStyle headlineLargeMobile = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontPrimary,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontPrimary,
    fontSize: 11,
    height: 14 / 11,
    letterSpacing: 0.05,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontPrimary,
    fontSize: 10,
    height: 13 / 10,
    letterSpacing: 0.05,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontSecondary,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontPrimary,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  // ── Light theme ───────────────────────────────────────────────────────────

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _fontPrimary,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
      shadow: Color(0x1A008080), // Updated shadow tint
    ),

    textTheme: const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: headlineSmall,
      iconTheme: IconThemeData(color: AppColors.primary, size: 22),
      actionsIconTheme: IconThemeData(
        color: AppColors.onSurfaceVariant,
        size: 22,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shadowColor: AppColors.cardShadow,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: _fontPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        disabledBackgroundColor: AppColors.primaryContainer,
        disabledForegroundColor: AppColors.onPrimary,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.outlineSubtle, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: _fontPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondary,
        textStyle: const TextStyle(
          fontFamily: _fontPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outlineSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outlineSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: const TextStyle(
        fontFamily: _fontSecondary,
        fontSize: 13,
        color: AppColors.onSurfaceVariant,
      ),
      hintStyle: const TextStyle(
        fontFamily: _fontSecondary,
        fontSize: 14,
        color: AppColors.outline,
      ),
      errorStyle: const TextStyle(
        fontFamily: _fontPrimary,
        fontSize: 11,
        color: AppColors.error,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      floatingLabelStyle: const TextStyle(
        fontFamily: _fontPrimary,
        fontSize: 11,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceContainer, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      horizontalTitleGap: 16,
      minVerticalPadding: 8,
      dense: false,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.outlineSubtle,
      thickness: 1,
      space: 0,
    ),

    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: TextStyle(
        fontFamily: _fontSecondary,
        fontSize: 13,
        color: AppColors.onSurface,
      ),
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.primarySubtle,
      deleteIconColor: AppColors.onSurfaceVariant,
      labelStyle: TextStyle(
        fontFamily: _fontPrimary,
        fontSize: 12,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: StadiumBorder(),
      side: BorderSide.none,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      selectedLabelStyle: TextStyle(
        fontFamily: _fontPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: _fontPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: TextStyle(
        fontFamily: _fontPrimary,
        fontSize: 13,
        color: AppColors.onPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      textStyle: TextStyle(
        fontFamily: _fontPrimary,
        fontSize: 11,
        color: AppColors.inverseOnSurface,
      ),
    ),

    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ── Dark theme ────────────────────────────────────────────────────────────

  static ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryFixed,
      onPrimary: AppColors.onPrimaryFixed,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondaryFixed,
      onSecondary: AppColors.onSecondaryFixed,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surfaceDim,
      onSurface: AppColors.inverseOnSurface,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      background: AppColors.primaryDark,
      onBackground: AppColors.inverseOnSurface,
      inverseSurface: AppColors.surface,
      onInverseSurface: AppColors.onSurface,
      inversePrimary: AppColors.inversePrimary,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: headlineSmall,
      iconTheme: IconThemeData(color: AppColors.onSurface, size: 22),
      actionsIconTheme: IconThemeData(
        color: AppColors.onSurfaceVariant,
        size: 22,
      ),
    ),
  );

  // ── Theme-Aware Gradient Helpers ──────────────────────────────────────────

  static LinearGradient getNavigationGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surfaceContainerLow,
          Theme.of(context).colorScheme.surfaceContainer,
        ],
        stops: const [0.0, 0.55, 1.0],
      );
    }
    return AppColors.primaryGradient;
  }

  static Color getNavigationBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Theme.of(context).colorScheme.surfaceContainerLowest;
    }
    return Theme.of(context).colorScheme.surface;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static TextStyle getResponsiveHeadline(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return isMobile ? headlineLargeMobile : headlineLarge;
  }

  static BoxDecoration cardDecoration({
    Color? color,
    double borderRadius = 20,
    bool hasBorder = true,
    bool hasShadow = true,
    BuildContext? context,
  }) {
    final effectiveColor =
        color ??
        (context != null
            ? Theme.of(context).cardTheme.color
            : AppColors.surfaceContainerLowest);
    final effectiveBorderColor = context != null
        ? Theme.of(context).dividerTheme.color
        : AppColors.surfaceContainer;
    final effectiveShadowColor = context != null
        ? Theme.of(context).shadowColor
        : AppColors.cardShadow;

    return BoxDecoration(
      color: effectiveColor ?? AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder
          ? Border.all(
              color: effectiveBorderColor ?? AppColors.surfaceContainer,
              width: 1,
            )
          : null,
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: effectiveShadowColor ?? AppColors.cardShadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  static const BoxDecoration heroPanelDecoration = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
  );

  static BoxDecoration badgeDecoration({Color? background, Color? border}) {
    return BoxDecoration(
      color: background ?? AppColors.primarySubtle,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border ?? AppColors.outlineSubtle, width: 1),
    );
  }
}

// ── Context extensions ────────────────────────────────────────────────────────

extension AppTextStyles on BuildContext {
  TextStyle get displayLarge => AppTheme.displayLarge;
  TextStyle get displayMedium => AppTheme.displayMedium;
  TextStyle get displaySmall => AppTheme.displaySmall;
  TextStyle get headlineLarge => AppTheme.headlineLarge;
  TextStyle get headlineMedium => AppTheme.headlineMedium;
  TextStyle get headlineSmall => AppTheme.headlineSmall;
  TextStyle get headlineLargeMobile => AppTheme.headlineLargeMobile;
  TextStyle get bodyLarge => AppTheme.bodyLarge;
  TextStyle get bodyMedium => AppTheme.bodyMedium;
  TextStyle get bodySmall => AppTheme.bodySmall;
  TextStyle get labelLarge => AppTheme.labelLarge;
  TextStyle get labelMedium => AppTheme.labelMedium;
  TextStyle get labelSmall => AppTheme.labelSmall;
  TextStyle get titleLarge => AppTheme.titleLarge;
  TextStyle get titleMedium => AppTheme.titleMedium;
  TextStyle get titleSmall => AppTheme.titleSmall;

  TextStyle getResponsiveHeadline() => AppTheme.getResponsiveHeadline(this);
}
