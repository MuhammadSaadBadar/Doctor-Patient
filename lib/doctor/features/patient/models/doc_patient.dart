import 'package:doctor/doctor/features/patient/models/doc_patient_card.dart';

class Patient {
  final String id;
  final String name;
  final String patientId;
  final int age;
  final String? imageUrl;
  final String status;
  final String statusColor;
  final String week;
  final String? edd;
  final String? lmp;
  final String? trimester;
  final String? bloodGroup;
  final String? bloodPressure;
  final int? bloodSugar;
  final int? kickCount;
  final double? weightGain;
  final String? latestReading;
  final String? phoneNumber;
  final String? email;

  Patient({
    required this.id,
    required this.name,
    required this.patientId,
    required this.age,
    this.imageUrl,
    required this.status,
    required this.statusColor,
    required this.week,
    this.edd,
    this.lmp,
    this.trimester,
    this.bloodGroup,
    this.bloodPressure,
    this.bloodSugar,
    this.kickCount,
    this.weightGain,
    this.latestReading,
    this.phoneNumber,
    this.email,
  });

  Patient copyWith({
    String? id,
    String? name,
    String? patientId,
    int? age,
    String? imageUrl,
    String? status,
    String? statusColor,
    String? week,
    String? edd,
    String? lmp,
    String? trimester,
    String? bloodGroup,
    String? bloodPressure,
    int? bloodSugar,
    int? kickCount,
    double? weightGain,
    String? latestReading,
    String? phoneNumber,
    String? email,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      patientId: patientId ?? this.patientId,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      week: week ?? this.week,
      edd: edd ?? this.edd,
      lmp: lmp ?? this.lmp,
      trimester: trimester ?? this.trimester,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      kickCount: kickCount ?? this.kickCount,
      weightGain: weightGain ?? this.weightGain,
      latestReading: latestReading ?? this.latestReading,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }

  factory Patient.fromPatientCard(PatientCard card) {
    // Compute trimester from LMP date if available
    String? computeTrimester() {
      if (card.profile?.lmpDate == null) return null;
      final lmpDate = card.profile!.lmpDate!;
      final now = DateTime.now();
      final diff = now.difference(lmpDate);
      final weeks = (diff.inDays / 7).floor();
      if (weeks < 13) return '1st';
      if (weeks < 27) return '2nd';
      return '3rd';
    }

    return Patient(
      id: card.id.toString(),
      name: card.fullName,
      patientId: card.patientId,
      age: card.profile?.age ?? 0,
      imageUrl: card.imageUrl,
      status: card.statusDisplay,
      statusColor: card.statusBgColor.toARGB32().toRadixString(16),
      week: card.week,
      edd: card.profile?.eddDate?.toString(),
      lmp: card.profile?.lmpDate?.toString(),
      trimester: computeTrimester(),
      bloodGroup: card.profile?.bloodGroup,
      bloodPressure: null,
      bloodSugar: null,
      kickCount: null,
      weightGain: null,
      latestReading: null,
      phoneNumber: card.phoneNumber,
      email: card.email,
    );
  }
}
