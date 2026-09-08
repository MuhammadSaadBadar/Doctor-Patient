// lib/patient/features/exercise_videos/controllers/video_player_manager.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:doctor/patient/features/exercise_videos/models/exercise_video.dart';

enum VideoPlaybackStatus {
  idle,
  initializing,
  ready,
  playing,
  paused,
  buffering,
  completed,
  error,
}

enum VideoSourceKind { directFile, externalWebPage }

enum VideoErrorType {
  none,
  invalidUrl,
  cleartextBlocked,
  networkError,
  codecError,
  corsBlocked,
  unknown,
}

extension VideoErrorTypeExtension on VideoErrorType {
  String get userMessage {
    switch (this) {
      case VideoErrorType.invalidUrl:
        return 'This video URL is invalid or malformed.';
      case VideoErrorType.cleartextBlocked:
        return 'This video cannot be played due to security restrictions. Please try a different video.';
      case VideoErrorType.networkError:
        return 'Network error. Check your connection and try again.';
      case VideoErrorType.codecError:
        return 'This video format is not supported on your device.';
      case VideoErrorType.corsBlocked:
        return 'This video cannot be played in the browser due to access restrictions.';
      case VideoErrorType.unknown:
      case VideoErrorType.none:
        return 'We couldn\'t load this video. Please try again.';
    }
  }
}

/// Owns the lifecycle of a single [VideoPlayerController] for the active
/// exercise video. Created per-route via the binding and disposed in
/// [onClose] to guarantee no leaked controllers / background audio.
class VideoPlayerManager extends GetxController {
  VideoPlayerController? _controller;
  int? _currentId;
  int _retryCount = 0;
  static const int _maxRetries = 2;
  bool _isDisposed = false;

  final status = VideoPlaybackStatus.idle.obs;
  final errorMessage = ''.obs;
  final errorType = VideoErrorType.none.obs;
  final isFullscreen = false.obs;
  final isRetrying = false.obs;

  VideoPlayerController? get controller => _controller;

  VideoSourceKind classify(String url) {
    final lower = url.toLowerCase();
    final isDirect = lower.endsWith('.mp4') ||
        lower.endsWith('.m3u8') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm');
    return isDirect ? VideoSourceKind.directFile : VideoSourceKind.externalWebPage;
  }

  VideoErrorType classifyError(dynamic error, String url) {
    final lower = url.toLowerCase();

    if (url.trim().isEmpty || !Uri.tryParse(url)!.isAbsolute) {
      return VideoErrorType.invalidUrl;
    }

    if (lower.startsWith('http://')) {
      return VideoErrorType.cleartextBlocked;
    }

    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('cors') ||
        errorStr.contains('access-control') ||
        errorStr.contains('cross-origin')) {
      return VideoErrorType.corsBlocked;
    }

    if (errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection') ||
        errorStr.contains('errno') ||
        errorStr.contains('handshake')) {
      return VideoErrorType.networkError;
    }

    if (errorStr.contains('codec') ||
        errorStr.contains('format') ||
        errorStr.contains('unsupported') ||
        errorStr.contains('demux')) {
      return VideoErrorType.codecError;
    }

    return VideoErrorType.unknown;
  }

  Future<void> load(ExerciseVideo video) async {
    if (!video.hasPlayableUrl) {
      status.value = VideoPlaybackStatus.error;
      errorType.value = VideoErrorType.invalidUrl;
      errorMessage.value = errorType.value.userMessage;
      return;
    }

    if (_currentId == video.id && _controller != null && _controller!.value.isInitialized) {
      return;
    }

    _isDisposed = false;
    await _disposeController();
    _currentId = video.id;
    _retryCount = 0;

    final kind = classify(video.videoUrl);
    if (kind == VideoSourceKind.externalWebPage) {
      status.value = VideoPlaybackStatus.ready;
      errorType.value = VideoErrorType.none;
      errorMessage.value = '';
      return;
    }

    await _initializeWithRetry(video);
  }

  Future<void> _initializeWithRetry(ExerciseVideo video) async {
    if (_isDisposed) return;

    status.value = VideoPlaybackStatus.initializing;
    errorType.value = VideoErrorType.none;
    errorMessage.value = '';
    isRetrying.value = _retryCount > 0;

    try {
      final c = VideoPlayerController.networkUrl(
        Uri.parse(video.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _controller = c;

      c.addListener(_onControllerTick);

      await c.initialize();

      if (_isDisposed) {
        await c.dispose();
        _controller = null;
        return;
      }

      if (!c.value.isInitialized) {
        throw Exception('Video failed to initialize');
      }

      _retryCount = 0;
      isRetrying.value = false;
      status.value = VideoPlaybackStatus.ready;
    } catch (e) {
      debugPrint('[VIDEO_PLAYER] init attempt ${_retryCount + 1} failed: $e');

      if (_isDisposed) return;

      final classifiedError = classifyError(e, video.videoUrl);

      if (_retryCount < _maxRetries && classifiedError == VideoErrorType.networkError) {
        _retryCount++;
        final delay = Duration(milliseconds: 500 * _retryCount);
        await Future.delayed(delay);
        if (!_isDisposed) {
          await _initializeWithRetry(video);
        }
        return;
      }

      errorType.value = classifiedError;
      errorMessage.value = classifiedError.userMessage;
      status.value = VideoPlaybackStatus.error;
      isRetrying.value = false;
      _retryCount = 0;
      await _disposeController();
    }
  }

  void _onControllerTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (_isDisposed) return;

    final v = c.value;
    if (v.hasError) {
      final classifiedError = classifyError(v.errorDescription, '');
      errorType.value = classifiedError;
      errorMessage.value = classifiedError.userMessage;
      status.value = VideoPlaybackStatus.error;
      return;
    }
    if (v.isCompleted) {
      status.value = VideoPlaybackStatus.completed;
      return;
    }
    if (v.isBuffering) {
      status.value = VideoPlaybackStatus.buffering;
    } else if (v.isPlaying) {
      status.value = VideoPlaybackStatus.playing;
    } else {
      status.value = VideoPlaybackStatus.paused;
    }
  }

  Future<void> play() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (status.value == VideoPlaybackStatus.error) return;
    await c.play();
    await _applyFullscreenLandscape();
  }

  Future<void> pause() async {
    final c = _controller;
    if (c == null) return;
    await c.pause();
  }

  Future<void> togglePlay() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (status.value == VideoPlaybackStatus.error) return;
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
      await _applyFullscreenLandscape();
    }
  }

  Future<void> seekTo(Duration position) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await c.seekTo(position);
  }

  Future<void> replay() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await c.seekTo(Duration.zero);
    await c.play();
    await _applyFullscreenLandscape();
  }

  Future<void> retry() async {
    if (_currentId == null) return;
    final video = ExerciseVideo(
      id: _currentId!,
      title: '',
      category: 'exercise',
      videoUrl: '',
    );
    _retryCount = 0;
    await load(video);
  }

  Future<void> _applyFullscreenLandscape() async {
    if (isFullscreen.value) return;
    try {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      isFullscreen.value = true;
    } catch (_) {
    }
  }

  Future<void> _restoreOrientation() async {
    if (!isFullscreen.value) return;
    try {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
    } catch (_) {}
    isFullscreen.value = false;
  }

  Future<void> _disposeController() async {
    final c = _controller;
    _controller = null;
    if (c != null) {
      try {
        c.removeListener(_onControllerTick);
        await c.pause();
        await c.dispose();
      } catch (e) {
        debugPrint('[VIDEO_PLAYER] dispose failed: $e');
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    isRetrying.value = false;
    unawaited(_restoreOrientation());
    unawaited(_disposeController());
    super.onClose();
  }
}
