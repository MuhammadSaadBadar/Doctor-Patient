import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum DoctorAvatarSize { small, medium, large }

class DoctorAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? firstName;
  final String? lastName;
  final double? size;
  final DoctorAvatarSize presetSize;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enableCacheBusting;

  const DoctorAvatar({
    super.key,
    this.imageUrl,
    this.firstName,
    this.lastName,
    this.size,
    this.presetSize = DoctorAvatarSize.medium,
    this.backgroundColor,
    this.textColor,
    this.enableCacheBusting = false,
  });

  /// Reactive avatar that listens to AuthController.currentUser
  const DoctorAvatar.reactive({
    super.key,
    this.firstName,
    this.lastName,
    this.size,
    this.presetSize = DoctorAvatarSize.medium,
    this.backgroundColor,
    this.textColor,
    this.enableCacheBusting = true,
    this.imageUrl, // ignored in reactive mode
  });

  String get _initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    if (first.isEmpty && last.isEmpty) return 'DR';
    return '$first$last'.toUpperCase();
  }

  double get _size {
    if (size != null) return size!;
    switch (presetSize) {
      case DoctorAvatarSize.small:
        return 32;
      case DoctorAvatarSize.medium:
        return 48;
      case DoctorAvatarSize.large:
        return 80;
    }
  }

  double get _fontSize {
    switch (presetSize) {
      case DoctorAvatarSize.small:
        return 12;
      case DoctorAvatarSize.medium:
        return 16;
      case DoctorAvatarSize.large:
        return 28;
    }
  }

  String? get _effectiveImageUrl {
    if (enableCacheBusting && imageUrl != null && imageUrl!.isNotEmpty) {
      // Check if URL already has cache-busting parameter
      if (imageUrl!.contains('?v=')) return imageUrl;
      return '$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}';
    }
    return imageUrl;
  }

  bool get _hasValidImage =>
      _effectiveImageUrl != null && _effectiveImageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Reactive mode: listen to AuthController.currentUser
    if (enableCacheBusting && imageUrl == null) {
      return Obx(() {
        final user = Get.find<AuthController>().currentUser.value;
        final reactiveImageUrl = user?.profilePictureUrl;
        final reactiveFirstName = user?.firstName ?? firstName;
        final reactiveLastName = user?.lastName ?? lastName;
        final reactiveInitials =
            (reactiveFirstName?.isNotEmpty == true
                ? reactiveFirstName![0]
                : '') +
            (reactiveLastName?.isNotEmpty == true ? reactiveLastName![0] : '');

        return _buildAvatar(
          context,
          imageUrl: reactiveImageUrl,
          initials: reactiveInitials.isEmpty
              ? 'DR'
              : reactiveInitials.toUpperCase(),
        );
      });
    }

    // Static mode
    return _buildAvatar(
      context,
      imageUrl: _effectiveImageUrl,
      initials: _initials,
    );
  }

  Widget _buildAvatar(
    BuildContext context, {
    required String? imageUrl,
    required String initials,
  }) {
    final theme = Theme.of(context);
    final effectiveBgColor =
        backgroundColor ?? theme.colorScheme.primaryContainer;
    final effectiveTextColor =
        textColor ?? theme.colorScheme.onPrimaryContainer;
    final hasValidImage = imageUrl != null && imageUrl.isNotEmpty;
    final accessToken = StorageService.instance.accessToken;
    final imageHeaders = accessToken == null || accessToken.isEmpty
        ? null
        : {'Authorization': 'Bearer $accessToken'};

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBgColor,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: hasValidImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: _size,
                height: _size,
                headers: imageHeaders,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitials(effectiveTextColor, initials),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildInitials(effectiveTextColor, initials);
                },
              )
            : _buildInitials(effectiveTextColor, initials),
      ),
    );
  }

  Widget _buildInitials(Color textColor, String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
