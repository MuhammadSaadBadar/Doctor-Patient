// lib/patient/features/dashboard/models/symptom.dart

class Symptom {
  final int id;
  final String name;

  Symptom({required this.id, required this.name});

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}
