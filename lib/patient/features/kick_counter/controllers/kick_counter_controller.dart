// lib/patient/features/kick_counter/controllers/kick_counter_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/kick_counter/models/kick_session.dart';
import 'package:doctor/patient/features/kick_counter/repositories/kick_counter_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickCounterController extends GetxController {
  final KickCounterRepository _repository = KickCounterRepository();

  // State
  final isLoading = true.obs;
  final isProcessing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Session data
  final allSessions = <KickSession>[].obs;
  final activeSession = Rx<KickSession?>(null);

  // Computed getters
  bool get isSessionActive => activeSession.value != null;
  int get kickCount => activeSession.value?.kickCount ?? 0;
  int get todayTotalKicks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allSessions
        .where((s) {
          final sessionDate = DateTime(
            s.logDate.year,
            s.logDate.month,
            s.logDate.day,
          );
          return sessionDate == today;
        })
        .fold(0, (sum, s) => sum + s.kickCount);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Load history to find active session and populate history
      final result = await _repository.getPaginatedSessions(
        page: 1,
        pageSize: 50,
      );

      if (result != null) {
        allSessions.assignAll(result.results);

        // Find active session (if any)
        try {
          activeSession.value = allSessions.firstWhere((s) => s.isActive);
        } catch (_) {
          activeSession.value = null;
        }

        debugPrint('[KICK_COUNTER] Loaded ${allSessions.length} sessions');
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load kick data. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[KICK_COUNTER] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startSession() async {
    if (isSessionActive) return;

    isProcessing.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final session = await _repository.startSession();

      if (session != null) {
        activeSession.value = session;
        allSessions.insert(0, session);
        Get.snackbar(
          'Session Started',
          'Kick counting session has begun',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to start session. Please try again.';
        Get.snackbar(
          'Error',
          'Failed to start session',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[KICK_COUNTER] Error starting session: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> recordKick() async {
    if (!isSessionActive || activeSession.value == null) return;

    // Optimistic UI update: immediately update local state
    final currentCount = activeSession.value!.kickCount;
    activeSession.value = activeSession.value!.copyWith(
      kickCount: currentCount + 1,
    );

    isProcessing.value = true;

    try {
      final updatedSession = await _repository.recordKick(
        activeSession.value!.id,
      );

      if (updatedSession != null) {
        // Verify backend matches optimistic update (or update with backend data)
        if (updatedSession.kickCount != currentCount + 1) {
          // Backend disagrees with optimistic update, use backend version
          activeSession.value = updatedSession;
        }

        // Update in allSessions list
        final index = allSessions.indexWhere((s) => s.id == updatedSession.id);
        if (index != -1) {
          allSessions[index] = updatedSession;
        }
      } else {
        // Revert optimistic update on failure
        activeSession.value = allSessions.firstWhere(
          (s) => s.id == activeSession.value!.id,
          orElse: () => activeSession.value!,
        );
        Get.snackbar(
          'Error',
          'Failed to record kick',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      activeSession.value = allSessions.firstWhere(
        (s) => s.id == activeSession.value!.id,
        orElse: () => activeSession.value!,
      );
      debugPrint('[KICK_COUNTER] Error recording kick: $e');
      Get.snackbar(
        'Error',
        'Failed to record kick',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> endSession() async {
    if (!isSessionActive || activeSession.value == null) return;

    isProcessing.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final endedSession = await _repository.endSession(
        activeSession.value!.id,
      );

      if (endedSession != null) {
        activeSession.value = null;

        // Update in allSessions list
        final index = allSessions.indexWhere((s) => s.id == endedSession.id);
        if (index != -1) {
          allSessions[index] = endedSession;
        }

        Get.snackbar(
          'Session Ended',
          'Recorded ${endedSession.kickCount} kicks',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to end session. Please try again.';
        Get.snackbar(
          'Error',
          'Failed to end session',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[KICK_COUNTER] Error ending session: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  // Navigation methods
  void navigateToHome() => Get.offAllNamed(AppRoutes.patientDashboard);
  void navigateToBooking() => Get.toNamed(AppRoutes.patientAppointments);
  void navigateToReports() => Get.toNamed('/patient/reports');
  void navigateToProfile() => Get.toNamed(AppRoutes.patientEditProfile);
  void navigateToHistory() => Get.toNamed(AppRoutes.patientKickCountHistory);
}
