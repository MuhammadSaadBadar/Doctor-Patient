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

  MedicineAdherence copyWith({int? taken, int? skipped, int? pending}) {
    return MedicineAdherence(
      taken: taken ?? this.taken,
      skipped: skipped ?? this.skipped,
      pending: pending ?? this.pending,
    );
  }

  int get total => taken + skipped + pending;

  // ✅ FIXED: Added percentage getter
  double get percentage => total > 0 ? (taken / total) * 100 : 0.0;
}
