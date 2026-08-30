// lib/patient/features/dashboard/models/medicine_adherence.dart

class MedicineAdherence {
  final int taken;
  final int skipped;
  final int pending;

  MedicineAdherence({
    required this.taken,
    required this.skipped,
    required this.pending,
  });

  factory MedicineAdherence.fromJson(Map<String, dynamic> json) {
    return MedicineAdherence(
      taken: json['taken'] ?? 0,
      skipped: json['skipped'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }

  int get total => taken + skipped + pending;
  double get adherencePercentage => total > 0 ? (taken / total) * 100 : 0;
}
