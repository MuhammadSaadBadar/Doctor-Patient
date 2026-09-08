// lib/patient/features/medicine_reminders/models/intake_log_summary.dart

import 'package:doctor/patient/features/medicine_reminders/models/medicine_intake_log.dart';

class IntakeLogSummary {
  final int taken;
  final int skipped;
  final int pending;
  final int total;
  final double adherenceRate;

  IntakeLogSummary({
    required this.taken,
    required this.skipped,
    required this.pending,
    required this.total,
    required this.adherenceRate,
  });

  factory IntakeLogSummary.fromLogs(List<MedicineIntakeLog> logs) {
    int taken = 0;
    int skipped = 0;
    int pending = 0;

    for (final log in logs) {
      if (log.isTaken)
        taken++;
      else if (log.isSkipped)
        skipped++;
      else if (log.isPending)
        pending++;
    }

    final total = taken + skipped + pending;
    final adherenceRate = total > 0 ? (taken / total) * 100 : 0.0;

    return IntakeLogSummary(
      taken: taken,
      skipped: skipped,
      pending: pending,
      total: total,
      adherenceRate: adherenceRate,
    );
  }

  String get formattedAdherence => '${adherenceRate.toInt()}%';
}
