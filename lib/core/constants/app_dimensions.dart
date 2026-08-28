// lib/core/constants/app_dimensions.dart

class AppDimensions {
  /// Standardized card height for mobile viewports (≤ 600dp)
  /// Matches AppointmentCard natural height on 360-414dp widths
  static const double mobileCardHeight = 178.0;

  /// Standardized card height for tablet/desktop viewports (> 600dp)
  static const double desktopCardHeight = 160.0;

  /// Card vertical padding (inner content)
  static const double cardPadding = 14.0;

  /// Card vertical margin (outer spacing)
  static const double cardVerticalMargin = 6.0;

  /// Standard spacing between card sections
  static const double sectionSpacing = 10.0;

  /// Small spacing between related elements
  static const double smallSpacing = 8.0;

  /// Standard CTA button height
  static const double ctaButtonHeight = 36.0;

  /// Avatar size for cards
  static const double avatarSize = 40.0;

  /// Avatar size for patient cards (slightly larger for emphasis)
  static const double patientAvatarSize = 44.0;

  /// Divider height
  static const double dividerHeight = 1.0;
}