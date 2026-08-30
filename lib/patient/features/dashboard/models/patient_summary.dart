// lib/patient/features/dashboard/models/patient_summary.dart

import 'package:doctor/patient/features/dashboard/models/pregnancy_progress.dart';
import 'package:doctor/patient/features/dashboard/models/blood_pressure_reading.dart';
import 'package:doctor/patient/features/dashboard/models/blood_sugar_reading.dart';
import 'package:doctor/patient/features/dashboard/models/diet_plan_summary.dart';
import 'package:doctor/patient/features/dashboard/models/dashboard_appointment.dart';
import 'package:doctor/patient/features/dashboard/models/symptom_log.dart';
import 'package:doctor/patient/features/dashboard/models/medicine_adherence.dart';

class PatientSummary {
  final PregnancyProgress? pregnancyProgress;
  final BloodPressureReading? latestBloodPressure;
  final BloodSugarReading? latestBloodSugar;
  final DietPlanSummary? activeDietPlan;
  final List<DashboardAppointment> upcomingAppointments;
  final List<SymptomLog> recentSymptoms;
  final MedicineAdherence medicineAdherence;

  PatientSummary({
    this.pregnancyProgress,
    this.latestBloodPressure,
    this.latestBloodSugar,
    this.activeDietPlan,
    required this.upcomingAppointments,
    required this.recentSymptoms,
    required this.medicineAdherence,
  });

  factory PatientSummary.fromJson(Map<String, dynamic> json) {
    return PatientSummary(
      pregnancyProgress: json['pregnancy_progress'] != null
          ? PregnancyProgress.fromJson(json['pregnancy_progress'])
          : null,
      latestBloodPressure: json['latest_blood_pressure'] != null
          ? BloodPressureReading.fromJson(json['latest_blood_pressure'])
          : null,
      latestBloodSugar: json['latest_blood_sugar'] != null
          ? BloodSugarReading.fromJson(json['latest_blood_sugar'])
          : null,
      activeDietPlan: json['active_diet_plan'] != null
          ? DietPlanSummary.fromJson(json['active_diet_plan'])
          : null,
      upcomingAppointments:
          (json['upcoming_appointments'] as List<dynamic>? ?? [])
              .map(
                (a) => DashboardAppointment.fromJson(a as Map<String, dynamic>),
              )
              .toList(),
      recentSymptoms: (json['recent_symptoms'] as List<dynamic>? ?? [])
          .map((s) => SymptomLog.fromJson(s as Map<String, dynamic>))
          .toList(),
      medicineAdherence: MedicineAdherence.fromJson(
        json['medicine_adherence'] ?? {},
      ),
    );
  }

  bool get hasPregnancyData => pregnancyProgress != null;
  bool get hasActiveDietPlan => activeDietPlan != null;
  bool get hasUpcomingAppointments => upcomingAppointments.isNotEmpty;
  bool get hasRecentSymptoms => recentSymptoms.isNotEmpty;
}
