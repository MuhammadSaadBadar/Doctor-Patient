import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';
import 'package:doctor/doctor/features/patient/models/doc_kick_session.dart';

class DoctorKickCountHistoryController extends GetxController {
  final DoctorPatientRepository _repository = DoctorPatientRepository();

  // State
  final sessions = <KickSession>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Patient info (from arguments)
  int? patientId;
  String patientName = '';
  String dueDate = '';
  String week = '';

  // Stats
  final stats = Stats.initial().obs;

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    if (patientId != null) {
      loadSessions();
    }
  }

  void _extractArguments() {
    final args = Get.arguments;
    if (args is Map) {
      patientId = args['patientId'] as int?;
      patientName = args['patientName'] as String? ?? 'Patient';
      dueDate = args['dueDate'] as String? ?? 'N/A';
      week = args['week'] as String? ?? '--';
    }
  }

  Future<void> loadSessions() async {
    if (patientId == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getKickSessions(
        patientId!,
        pageSize: 50,
      );

      sessions.value =
          response.map((json) => KickSession.fromJson(json)).toList()
            ..sort((a, b) => b.logDate.compareTo(a.logDate));

      _updateStats();
    } catch (e) {
      errorMessage.value = 'Failed to load kick count history: $e';
      debugPrint('[KICK_HISTORY] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStats() {
    if (sessions.isEmpty) {
      stats.value = Stats.initial();
      return;
    }

    final totalKicks = sessions.fold(0, (sum, s) => sum + s.kickCount);
    final totalSessions = sessions.length;
    final average = totalSessions > 0 ? totalKicks / totalSessions : 0;

    // Calculate trend based on last 5 sessions
    final sorted = List<KickSession>.from(sessions)
      ..sort((a, b) => a.logDate.compareTo(b.logDate));

    final trend = _calculateTrend(sorted);

    stats.value = Stats(
      totalSessions: totalSessions,
      totalKicks: totalKicks,
      averagePerSession: average,
      trend: trend,
    );
  }

  String _calculateTrend(List<KickSession> sorted) {
    if (sorted.length < 3) return 'Stable';

    final recent = sorted.take(3).map((s) => s.kickCount).toList();
    final older = sorted
        .skip(sorted.length - 3)
        .map((s) => s.kickCount)
        .toList();

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    if (recentAvg > olderAvg * 1.1) return 'Increasing';
    if (recentAvg < olderAvg * 0.9) return 'Decreasing';
    return 'Stable';
  }

  Future<void> refreshData() async {
    await loadSessions();
  }

  // Computed getters
  Map<String, List<KickSession>> get groupedSessions {
    final groups = <String, List<KickSession>>{};

    for (final session in sessions) {
      final group = session.displayGroup;
      groups.putIfAbsent(group, () => []);
      groups[group]!.add(session);
    }

    // Ensure order: Today, Yesterday, Older
    final ordered = <String, List<KickSession>>{};
    const order = ['Today', 'Yesterday', 'Older'];
    for (final key in order) {
      if (groups.containsKey(key)) {
        ordered[key] = groups[key]!;
      }
    }
    return ordered;
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class Stats {
  final int totalSessions;
  final int totalKicks;
  final num averagePerSession;
  final String trend;

  Stats({
    required this.totalSessions,
    required this.totalKicks,
    required this.averagePerSession,
    required this.trend,
  });

  static Stats initial() {
    return Stats(
      totalSessions: 0,
      totalKicks: 0,
      averagePerSession: 0,
      trend: 'Stable',
    );
  }
}
