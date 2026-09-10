// lib/patient/features/kick_counter/controllers/kick_history_controller.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/kick_counter/models/kick_daily_summary.dart';
import 'package:doctor/patient/features/kick_counter/models/kick_session.dart';
import 'package:doctor/patient/features/kick_counter/models/paginated_kick_session.dart';
import 'package:doctor/patient/features/kick_counter/repositories/kick_counter_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KickHistoryController extends GetxController {
  final KickCounterRepository _repository = KickCounterRepository();

  // State
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data
  final allSessions = <KickSession>[].obs;
  final paginatedData = Rx<PaginatedKickSessionList?>(null);

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final totalCount = 0.obs;

  // Computed getters
  bool get hasSessions => allSessions.isNotEmpty;
  bool get isEmpty => !hasSessions && !isLoading.value;

  // Patient ID from arguments
  int? get patientId => Get.arguments?['patientId'] as int?;

  // Grouped by date
  Map<String, List<KickSession>> get groupedSessions {
    final groups = <String, List<KickSession>>{};

    for (final session in allSessions) {
      final dateKey = session.logDate.toIso8601String().split('T')[0];
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(session);
    }

    // Sort each group by time (newest first)
    for (final key in groups.keys) {
      groups[key]!.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }

    return groups;
  }

  // Daily summaries
  List<KickDailySummary> get dailySummaries {
    final summaries = <KickDailySummary>[];

    for (final entry in groupedSessions.entries) {
      summaries.add(
        KickDailySummary.fromSessions(date: entry.key, sessions: entry.value),
      );
    }

    // Sort by date (newest first)
    summaries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return summaries;
  }

  // Sorted date keys
  List<String> get sortedDateKeys {
    final keys = groupedSessions.keys.toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      allSessions.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = allSessions.isEmpty;
    isLoadingMore.value = allSessions.isNotEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getPaginatedSessions(
        page: currentPage.value,
        pageSize: 20,
        patientId: patientId,
      );

      if (result != null) {
        allSessions.addAll(result.results);
        paginatedData.value = result;
        hasMoreData.value = result.hasNext;
        totalCount.value = result.count;
        currentPage.value++;

        debugPrint(
          '[KICK_HISTORY] Loaded ${allSessions.length} of ${result.count} sessions',
        );
      } else {
        hasError.value = true;
        errorMessage.value = TranslationKeys.commonTryAgain.tr;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = TranslationKeys.commonTryAgain.tr;
      debugPrint('[KICK_HISTORY] Error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadHistory(refresh: true);
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await loadHistory();
  }

  // Navigation
  void navigateToSessionDetail(int sessionId) {
    final session = allSessions.firstWhereOrNull((s) => s.id == sessionId);
    if (session != null) {
      Get.bottomSheet(
        _buildSessionDetailSheet(session),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    }
  }

  void navigateToKickCounter() {
    Get.back();
  }

  // Helper methods
  List<KickSession> getSessionsForDate(String dateKey) {
    return groupedSessions[dateKey] ?? [];
  }

  int getTotalKicksForDate(String dateKey) {
    final sessions = getSessionsForDate(dateKey);
    return sessions.fold(0, (sum, s) => sum + s.kickCount);
  }

  String formatDate(String dateKey) {
    final date = DateTime.tryParse(dateKey);
    if (date == null) return dateKey;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return TranslationKeys.commonToday.tr;
    }
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return TranslationKeys.commonYesterday.tr;
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour > 12
        ? localTime.hour - 12
        : (localTime.hour == 0 ? 12 : localTime.hour);
    final minute = localTime.minute.toString().padLeft(2, '0');
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  // ==================== UI BUILDERS ====================

  Widget _buildDetailRow(String label, String value) {
    final colorScheme = Get.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetailSheet(KickSession session) {
    final colorScheme = Get.theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            TranslationKeys.kickCounterSessionDetails.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            TranslationKeys.appointmentsDate.tr,
            _formatLogDate(session.logDate),
          ),
          _buildDetailRow(
            TranslationKeys.kickCounterStartTime.tr,
            formatTime(session.startedAt),
          ),
          _buildDetailRow(
            TranslationKeys.kickCounterEndTime.tr,
            session.endedAt != null
                ? formatTime(session.endedAt!)
                : TranslationKeys.kickCounterActive.tr,
          ),
          _buildDetailRow(
            TranslationKeys.appointmentsDuration.tr,
            session.duration,
          ),
          _buildDetailRow(
            TranslationKeys.kickCounterKickCount.tr,
            '${session.kickCount} ${TranslationKeys.kickCounterKicks.tr}',
          ),
          _buildDetailRow(
            TranslationKeys.kickCounterStatus.tr,
            session.isActive
                ? TranslationKeys.kickCounterActive.tr
                : TranslationKeys.kickCounterCompleted.tr,
          ),
          if (session.events.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              TranslationKeys.kickCounterTimeline.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: session.events.length,
                itemBuilder: (context, index) {
                  final event = session.events[index];
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      TranslationKeys.kickCounterKickNumber.tr.replaceAll(
                        '@number',
                        '${index + 1}',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      formatTime(event.tappedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(TranslationKeys.commonClose.tr),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatLogDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
