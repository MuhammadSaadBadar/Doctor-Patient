// lib/patient/features/exercise_videos/widgets/video_player_overlay.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/exercise_videos/controllers/video_player_manager.dart';
import 'package:doctor/patient/features/exercise_videos/models/exercise_video.dart';
import 'package:doctor/patient/features/exercise_videos/models/exercise_video_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayerOverlay extends StatefulWidget {
  final ExerciseVideo video;

  const VideoPlayerOverlay({super.key, required this.video});

  @override
  State<VideoPlayerOverlay> createState() => _VideoPlayerOverlayState();
}

class _VideoPlayerOverlayState extends State<VideoPlayerOverlay> {
  late final VideoPlayerManager _manager;
  late final String _videoUrl;
  late final VideoSourceKind _kind;

  WebViewController? _webController;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _manager = Get.put(VideoPlayerManager(), tag: 'player_${widget.video.id}');
    _videoUrl = widget.video.videoUrl;
    _kind = _manager.classify(_videoUrl);

    if (_kind == VideoSourceKind.externalWebPage) {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF000000))
        ..loadRequest(Uri.parse(_videoUrl));
    } else {
      _manager.load(widget.video);
    }
  }

  @override
  void dispose() {
    Get.delete<VideoPlayerManager>(tag: 'player_${widget.video.id}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cs, textScale),
            Expanded(child: _buildBody()),
            _buildFooter(cs, textScale),
          ],
        ),
      ),
    );
  }

  // lib/patient/features/exercise_videos/widgets/video_player_overlay.dart

  // ... Keep all imports and class definitions the same ...

  // Fix _buildHeader method - remove Flexible wrapper
  Widget _buildHeader(ColorScheme cs, TextScaler textScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black.withValues(alpha: 0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ Added
              children: [
                Text(
                  // ✅ Removed Flexible wrapper
                  widget.video.title,
                  style: TextStyle(
                    fontSize: textScale.scale(16).clamp(14.0, 20.0).toDouble(),
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _badge(
                      cs.onPrimary,
                      widget.video.categoryColor,
                      widget.video.categoryLabel,
                    ),
                    if (!widget.video.isForAllTrimesters) ...[
                      const SizedBox(width: 4),
                      _badge(
                        cs.onPrimary,
                        widget.video.trimesterColor,
                        widget.video.trimesterLabel,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: cs.onPrimary),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  // Fix _buildFooter method - remove Flexible wrapper
  Widget _buildFooter(ColorScheme cs, TextScaler textScale) {
    final description = widget.video.description;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.black.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Added
        children: [
          if (description != null && description.isNotEmpty)
            Text(
              // ✅ Removed Flexible wrapper
              description,
              style: TextStyle(
                fontSize: textScale.scale(11).clamp(9.0, 15.0).toDouble(),
                color: cs.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.verified_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                // ✅ Removed Flexible wrapper
                'Expert Certified \u2022 OB/GYN Approved',
                style: TextStyle(
                  fontSize: textScale.scale(10).clamp(8.0, 14.0).toDouble(),
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(Color textColor, Color bg, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_kind == VideoSourceKind.externalWebPage) {
      return _webController == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : WebViewWidget(controller: _webController!);
    }

    return Obx(() {
      final status = _manager.status.value;
      final isRetrying = _manager.isRetrying.value;

      if (isRetrying && status == VideoPlaybackStatus.initializing) {
        return _buildRetryingLoading();
      }

      switch (status) {
        case VideoPlaybackStatus.idle:
        case VideoPlaybackStatus.initializing:
          return _buildLoadingShimmer();
        case VideoPlaybackStatus.error:
          return _buildError(
            _manager.errorMessage.value,
            _manager.errorType.value,
          );
        case VideoPlaybackStatus.ready:
        case VideoPlaybackStatus.paused:
        case VideoPlaybackStatus.playing:
        case VideoPlaybackStatus.buffering:
        case VideoPlaybackStatus.completed:
          return _buildNativeSurface();
      }
    });
  }

  Widget _buildLoadingShimmer() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShimmerBox(
            width: 280,
            height: 200,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),
          _ShimmerBox(width: 200, height: 16),
          const SizedBox(height: 8),
          _ShimmerBox(width: 120, height: 12),
        ],
      ),
    );
  }

  Widget _buildRetryingLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Retrying video...',
            style: TextStyle(color: Colors.white70, fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeSurface() {
    final controller = _manager.controller;
    if (controller == null || !controller.value.isInitialized) {
      return _buildLoadingShimmer();
    }

    return GestureDetector(
      onTap: () => setState(() => _controlsVisible = !_controlsVisible),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          Obx(() {
            if (!_manager.isFullscreen.value || !_controlsVisible) {
              return const SizedBox.shrink();
            }
            return _buildControls(controller);
          }),
          Obx(() {
            if (_manager.status.value != VideoPlaybackStatus.buffering) {
              return const SizedBox.shrink();
            }
            return _buildBufferingIndicator();
          }),
          Obx(() {
            if (_manager.status.value != VideoPlaybackStatus.completed) {
              return const SizedBox.shrink();
            }
            return _buildReplayOverlay();
          }),
        ],
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Buffering...',
              style: TextStyle(color: Colors.white70, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(VideoPlayerController controller) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              iconSize: 64,
              icon: Icon(
                controller.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white,
              ),
              onPressed: _manager.togglePlay,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).colorScheme.primary,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplayOverlay() {
    final textScale = MediaQuery.textScalerOf(context);
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                'Workout complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textScale.scale(16).clamp(14.0, 22.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _manager.replay,
                icon: const Icon(Icons.replay_rounded),
                label: Text(TranslationKeys.exerciseWatchAgain.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message, VideoErrorType errorType) {
    final textScale = MediaQuery.textScalerOf(context);
    final icon = _getErrorIcon(errorType);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 56),
            const SizedBox(height: 12),
            Text(
              message.isEmpty ? 'Unable to play this video.' : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _manager.load(widget.video),
              icon: const Icon(Icons.refresh_rounded),
                label: Text(TranslationKeys.exerciseTryAgain.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (errorType == VideoErrorType.cleartextBlocked) ...[
              const SizedBox(height: 12),
              Text(
                'This video uses an insecure connection and cannot be played.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: textScale.scale(9).clamp(7.0, 13.0),
                ),
              ),
            ],
            if (errorType == VideoErrorType.corsBlocked) ...[
              const SizedBox(height: 12),
              Text(
                'This video is blocked by the browser. Try opening it directly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: textScale.scale(9).clamp(7.0, 13.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(VideoErrorType errorType) {
    switch (errorType) {
      case VideoErrorType.cleartextBlocked:
        return Icons.lock_rounded;
      case VideoErrorType.corsBlocked:
        return Icons.public_off_rounded;
      case VideoErrorType.networkError:
        return Icons.wifi_off_rounded;
      case VideoErrorType.codecError:
        return Icons.videocam_off_rounded;
      case VideoErrorType.invalidUrl:
        return Icons.link_off_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFF2A2A2A),
                Color(0xFF3A3A3A),
                Color(0xFF2A2A2A),
              ],
            ),
          ),
        );
      },
    );
  }
}
