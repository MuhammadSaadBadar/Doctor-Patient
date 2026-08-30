import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/doctor/features/patient/repositories/doc_patient_repository.dart';
import 'package:doctor/doctor/features/patient/models/doc_patient.dart';
import 'package:doctor/doctor/features/patient/models/doc_symptom.dart';
import 'package:doctor/doctor/features/patient/models/doc_water_intake.dart';
import 'package:doctor/doctor/features/patient/models/doc_appointment.dart';

class DoctorPatientDetailController extends GetxController {
  final DoctorPatientRepository _repository = DoctorPatientRepository();

  // State variables
  final patient = Rx<Patient?>(null);
  final symptoms = <Symptom>[].obs;
  final isLoading = true.obs;
  final isLoadingSymptoms = false.obs;

  // Upcoming appointments state
  final upcomingAppointments = <Appointment>[].obs;
  final isLoadingAppointments = false.obs;

  // Water intake state
  final waterIntakeEntries = <WaterIntakeEntry>[].obs;
  final todayWaterIntake = 0.obs;
  final isLoadingWaterIntake = false.obs;
  final isLoggingWaterIntake = false.obs;

  // Chart data state
  final bloodPressureHistory = <Map<String, dynamic>>[].obs;
  final bloodSugarHistory = <Map<String, dynamic>>[].obs;

  final hasError = false.obs;
  final errorMessage = ''.obs;
  final selectedTab = 0.obs; // Default to Overview tab

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;

  // Patient ID — resolved from route arguments in onReady
  int? _patientId;

  // Public getter for patient ID
  int? get patientId => _patientId;

  @override
  void onInit() {
    super.onInit();
    // Resolve patient ID immediately from arguments if available at init time.
    // GetX sets arguments before calling onInit when using named routes, so
    // this handles the common case.  onReady() is the true guaranteed-safe
    // hook; _loadPatientData() guards against double-loading via isLoading.
    final args = Get.arguments;
    if (args is Map) {
      _patientId = args['patientId'] as int?;
    }
    if (_patientId != null) {
      _loadPatientData();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // onReady() fires after the first frame — arguments are guaranteed to be
    // available here.  Only kick off loading if onInit() didn't already do it.
    if (_patientId == null) {
      final args = Get.arguments;
      if (args is Map) {
        _patientId = args['patientId'] as int?;
      }
      _loadPatientData();
    }
  }

  Future<void> _loadPatientData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      if (_patientId == null) {
        debugPrint('[PATIENT_DETAIL] No patient ID provided');
        patient.value = null;
        symptoms.value = [];
        upcomingAppointments.value = [];
        return;
      }

      debugPrint('[PATIENT_DETAIL] Loading patient $_patientId');

      // Fetch patient details
      final patientData = await _repository.getPatientById(_patientId!);
      if (patientData != null) {
        // Convert PatientCard to Patient model
        patient.value = Patient.fromPatientCard(patientData);
      } else {
        hasError.value = true;
        errorMessage.value = 'Patient not found. Please try again.';
        patient.value = null;
      }

      // Load symptoms
      _loadSymptoms();

      // Load additional data in background
      _loadAdditionalData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load patient details. Please try again.';
      debugPrint('[PATIENT_DETAIL] Error: $e');
      patient.value = null;
      symptoms.value = [];
      upcomingAppointments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSymptoms() async {
    isLoadingSymptoms.value = true;
    try {
      if (_patientId != null) {
        final symptomLogs = await _repository.getPatientSymptoms(_patientId!);
        // Convert to Symptom model
        symptoms.value = symptomLogs
            .map((log) => Symptom.fromLog(log))
            .toList();
      } else {
        symptoms.value = [];
      }
    } catch (e) {
      debugPrint('[PATIENT_DETAIL] Error loading symptoms: $e');
      symptoms.value = [];
    } finally {
      isLoadingSymptoms.value = false;
    }
  }

  Future<void> _loadUpcomingAppointments() async {
    if (_patientId == null) return;
    isLoadingAppointments.value = true;
    try {
      final appointments = await _repository.getPatientAppointments(
        _patientId!,
        status: 'upcoming',
        pageSize: 5,
      );
      upcomingAppointments.value = appointments
          .map((a) => Appointment.fromJson(a))
          .toList();
    } catch (e) {
      debugPrint('[PATIENT_DETAIL] Error loading upcoming appointments: $e');
      upcomingAppointments.value = [];
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  Future<void> _loadAdditionalData() async {
    if (_patientId == null) return;

    // Load pregnancy progress
    try {
      final progress = await _repository.getPatientPregnancyProgress(
        _patientId!,
      );
      if (progress != null) {
        final current = patient.value;
        if (current != null) {
          patient.value = current.copyWith(
            edd: progress['edd_date'],
            trimester: _getTrimester(progress['current_week']),
            week: 'Week ${progress['current_week']}',
          );
        }
      }
    } catch (e) {
      debugPrint('[PATIENT_DETAIL] Error loading pregnancy progress: $e');
    }

    // Load blood pressure history and latest reading
    try {
      final bpReadings = await _repository.getBloodPressureReadings(
        _patientId!,
        pageSize: 6,
      );
      if (bpReadings.isNotEmpty) {
        bloodPressureHistory.value = bpReadings.reversed
            .toList(); // Oldest first for chart
        final bp = bpReadings.first;
        final current = patient.value;
        if (current != null) {
          patient.value = current.copyWith(
            bloodPressure: '${bp['systolic'] ?? 0}/${bp['diastolic'] ?? 0}',
          );
        }
      } else {
        bloodPressureHistory.value = [];
      }
    } catch (e) {
      debugPrint('[PATIENT_DETAIL] Error loading blood pressure: $e');
    }

    // Load blood sugar history and latest reading
    try {
      final bsReadings = await _repository.getBloodSugarReadings(
        _patientId!,
        pageSize: 20,
      );
      if (bsReadings.isNotEmpty) {
        bloodSugarHistory.value = bsReadings.reversed
            .toList(); // Oldest first for chart

        // Separate by reading context
        final fastingReadings = bsReadings
            .where((r) => r['reading_context'] == 'fasting')
            .toList();
        final postMealReadings = bsReadings
            .where((r) => r['reading_context'] == 'post_meal')
            .toList();

        final current = patient.value;
        if (current != null) {
          // Store latest fasting reading as primary bloodSugar value
          if (fastingReadings.isNotEmpty) {
            patient.value = current.copyWith(
              bloodSugar:
                  (fastingReadings.first['value_mg_dl'] as num?)?.toInt() ?? 0,
            );
          } else if (postMealReadings.isNotEmpty) {
            // Fallback to post-meal if no fasting
            patient.value = current.copyWith(
              bloodSugar:
                  (postMealReadings.first['value_mg_dl'] as num?)?.toInt() ?? 0,
            );
          }
        }
      } else {
        bloodSugarHistory.value = [];
      }
    } catch (e) {
      debugPrint('[PATIENT_DETAIL] Error loading blood sugar: $e');
    }

    // Load kick count
    try {
      final todayKicks = await _repository.getTodaysKickCount(_patientId!);
      final current = patient.value;
      if (current != null) {
        patient.value = current.copyWith(kickCount: todayKicks);
      }
    } catch (e) {
      debugPrint('[PATIENT_DETAIL] Error loading kick count: $e');
    }

    // Load water intake
    _loadWaterIntake();

    // Load upcoming appointments
    _loadUpcomingAppointments();
  }

  Future<void> _loadWaterIntake() async {
    if (_patientId == null) return;

    isLoadingWaterIntake.value = true;
    try {
      // Load today's total
      final todayTotal = await _repository.getTodaysWaterIntake(_patientId!);
      todayWaterIntake.value = todayTotal;

      // Load recent entries (first page)
      final entries = await _repository.getWaterIntake(
        _patientId!,
        pageSize: 10,
      );
      waterIntakeEntries.value = entries
          .map((e) => WaterIntakeEntry.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('[PATIENT_DETAIL] Error loading water intake: $e');
    } finally {
      isLoadingWaterIntake.value = false;
    }
  }

  String _getTrimester(int? week) {
    if (week == null) return '1st';
    if (week < 13) return '1st';
    if (week < 27) return '2nd';
    return '3rd';
  }

  void loadPatientData() async {
    await _loadPatientData();
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  Future<void> refreshData() async {
    await _loadPatientData();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
